//
//  AuthManager.swift
//  tumble-ios
//
//  Created by Adis Veletanlic on 2023-02-13.
//

import Foundation

class AuthManager: AuthManagerProtocol {
    
    private let urlSession: URLSession
    private let serialQueue = OperationQueue()
    private let encoder = JSONEncoder.shared
    private let decoder = JSONDecoder.shared
    private let urlRequestUtils = URLRequestUtils.shared
    private let keychainManager = KeyChainManager()
    
    init() {
        
        // Limit amount of concurrent operations to avoid
        // potentially strange state behavior
        serialQueue.maxConcurrentOperationCount = 1
        serialQueue.qualityOfService = .userInitiated
        self.urlSession = URLSession.shared
    }
    
    var refreshToken: Token? {
        get {
            getToken(tokenType: .refreshToken)
        }
        set {
            setToken(newValue: newValue, tokenType: .refreshToken)
        }
    }
    
    var user: TumbleUser? {
        get {
            getUser()
        }
        set {
            setUser(newValue: newValue)
        }
    }
    
    func autoLoginUser(completionHandler: @escaping (Result<TumbleUser, Error>) -> Void) -> Void {
        serialQueue.addOperation {
            let semaphore = DispatchSemaphore(value: 0)
            AppLogger.shared.debug("Running auto login ...")
            self.processAutoLogin(completionHandler: { (result: Result<TumbleUser, Error>) in
                completionHandler(result)
                semaphore.signal()
            })
            _ = semaphore.wait(timeout: DispatchTime.distantFuture)
        }
    }
    
    
    func loginUser(user: Request.KronoxUserLogin, completionHandler: @escaping (Result<TumbleUser, Error>) -> Void) {
        // Process all token requests using private serial queue to avoid issues with race conditions
        // when multiple credentials / login requests can lead auth manager in an unpredictable state
        serialQueue.addOperation {
            let semaphore = DispatchSemaphore(value: 0)
            
            self.processLogin(user: user, completionHandler: { (result: Result<TumbleUser, Error>) in
                completionHandler(result)
                semaphore.signal()
            })
            _ = semaphore.wait(timeout: DispatchTime.distantFuture)
        }
    }
    
    // This method will clear all tokens both from memory and persistent storage.
    // Most common use case for this method is user logout.
    func logOutUser(completionHandler: ((Result<Int, Error>) -> Void)? = nil) {
        if OperationQueue.current == serialQueue {
            self.clearTokensAndKeyChain(of: [TokenType.refreshToken.rawValue, "tumble-user"], completionHandler: completionHandler)
        } else {
            serialQueue.addOperation {
                self.clearTokensAndKeyChain(of: [TokenType.refreshToken.rawValue, "tumble-user"], completionHandler: completionHandler)
            }
        }
    }
}




// Private methods with specific functions in file
extension AuthManager {
    
    private func clearTokensAndKeyChain(of tokensToDelete: [String], completionHandler: ((Result<Int, Error>) -> Void)? = nil) {
        refreshToken = nil
        clearKeyChain(of: tokensToDelete, completionHandler: completionHandler)
    }
    
    
    private func clearKeyChain(of tokensToDelete: [String], completionHandler: ((Result<Int, Error>) -> Void)?) {
        guard let school = self.getDefaultSchool() else {
            completionHandler?(.failure(.internal(reason: "Failed to get default school")))
            return
        }

        let tokensToDelete = [TokenType.refreshToken.rawValue, TokenType.sessionToken.rawValue]

        for token in tokensToDelete {
            self.keychainManager.deleteKeyChain(for: token, account: school.name) { result in
                switch result {
                case .success:
                    AppLogger.shared.debug("Successfully cleared keychain of \(token)")
                case .failure(let failure):
                    AppLogger.shared.critical("Failed to clear keychain of \(token) -> \(failure.localizedDescription)")
                    completionHandler?(.failure(.internal(reason: "Failed to modify keychain for value '\(token)'")))
                    return
                }
            }
        }

        completionHandler?(.success(tokensToDelete.count))
    }

    
    private func processAutoLoginWithKeyChainCredentials(
        completionHandler: @escaping (Result<TumbleUser, Error>) -> Void) -> Void {
            if let school = self.getDefaultSchool(), let user = self.user {
                let userRequest = Request.KronoxUserLogin(username: user.username, password: user.password)
                AppLogger.shared.debug("Running login with keychain credentials for user: \(userRequest.username)", source: "AuthManager")
                let urlRequest = urlRequestUtils.createUrlRequest(
                    method: .post,
                    endpoint: .login(schoolId: String(school.id)),
                    body: userRequest
                )
                if let urlRequest = urlRequest {
                    urlSession.dataTask(with: urlRequest, completionHandler: { [unowned self] data, response, error in
                        self.handleAuthResponse(
                            data: data,
                            response: response,
                            error: error as? Error,
                            completionHandler: completionHandler)
                    }).resume()
                } else {
                    AppLogger.shared.critical("Could not create URLRequest object")
                    completionHandler(.failure(.generic(reason: "Failed to instantiate URLRequest object")))
                }
            } else {
                AppLogger.shared.critical("Missing school/keychain user ...")
                completionHandler(.failure(.generic(reason: "No school selected or no user available in KeyChain")))
            }
    }
    
    /// Function to log in user with credentials passed
    /// from account page when entered credentials. On successful response,
    /// the user is stored securely in the keychain as TumbleUser
    private func processLogin(
        user: Request.KronoxUserLogin,
        completionHandler: @escaping (Result<TumbleUser, Error>) -> Void) {
            if let school = self.getDefaultSchool() {
                let urlRequest = urlRequestUtils.createUrlRequest(
                    method: .post,
                    endpoint: .login(schoolId: String(school.id)),
                    body: user
                )
                if let urlRequest = urlRequest {
                    urlSession.dataTask(with: urlRequest, completionHandler: { [unowned self] data, response, error in
                        self.handleAuthResponse(
                            password: user.password,
                            data: data,
                            response: response,
                            error: error as? Error,
                            completionHandler: completionHandler)
                    }).resume()
                }
            } else {
                completionHandler(.failure(.generic(reason: "No school selected")))
            }
    }
    
    private func processAutoLogin(completionHandler: @escaping (Result<TumbleUser, Error>) -> Void) -> Void {
        // If there is a school selected and an available refresh token
        if let school = self.getDefaultSchool(), let token = self.refreshToken {
            let urlRequest = urlRequestUtils.createUrlRequest(
                method: .get,
                endpoint: .users(schoolId: String(school.id)),
                refreshToken: token.value
            )
            if let urlRequest = urlRequest {
                urlSession.dataTask(with: urlRequest, completionHandler: { [unowned self] data, response, error in
                    self.handleAuthResponse(
                        data: data,
                        response: response,
                        error: error as? Error,
                        completionHandler: { [unowned self](result: Result<TumbleUser, Error>) in
                        switch result {
                        case .success(let user):
                            completionHandler(.success(user))
                            break
                        case .failure(let failure):
                            AppLogger.shared.critical("Missing refresh token or is expired -> \(failure)")
                            self.processAutoLoginWithKeyChainCredentials(completionHandler: completionHandler)
                        }
                    })
                }).resume()
            }
        } else {
            AppLogger.shared.debug("Missing school/token ... Attempting login with keychain credentials instead", source: "AuthManager")
            self.processAutoLoginWithKeyChainCredentials(completionHandler: completionHandler)
        }
    }
    
    private func handleAuthResponse(
        password: String? = nil,
        data: Data?,
        response: URLResponse?,
        error: Error?,
        completionHandler: @escaping (Result<TumbleUser, Error>) -> Void) {
            if let data = data, let result = try? self.decoder.decode(Response.KronoxUser.self, from: data) {
                AppLogger.shared.debug("Retrieved new refresh token: \(result.refreshToken)")
                self.refreshToken = Token(value: result.refreshToken, createdDate: Date.now)
                // Replace old user with new user if
                // the call instance contains a new password.
                // Completion always returns instance of TumbleUser
                if let password = password {
                    AppLogger.shared.debug("Creating new user")
                    let newUser = TumbleUser(username: result.username, password: password, name: result.name)
                    AppLogger.shared.debug("Registering new user \(result.username)")
                    self.user = newUser
                    completionHandler(.success(newUser))
                    return
                } else if let user = self.user {
                    completionHandler(.success(user))
                    return
                }
                
            } else if let statusCode = (response as? HTTPURLResponse)?.statusCode, statusCode > 299 {
                // In case we got an error while using refresh token, we want to clear token storage - there's no way
                // to recover from this
                clearTokensAndKeyChain(of: [TokenType.refreshToken.rawValue])
                completionHandler(.failure(.generic(reason: "Could not retrieve any tokens")))
                return
                
            } else {
                // Any other error from NSURLErrorDomain (e.g internet offline) - we won't clear token storage
                completionHandler(.failure(.generic(reason: error?.localizedDescription ?? "Service unavailable")))
            }
    }
    
    private func getDefaultSchool() -> School? {
        
        let id: Int = UserDefaults.standard.object(forKey: StoreKey.school.rawValue) as? Int ?? -1
        if id == -1 {
            return nil
        }
        return schools.first(where: {$0.id == id})!
    }
    
    private func getToken(tokenType: TokenType) -> Token? {
        if let school = self.getDefaultSchool() {
            if let data = self.keychainManager.readKeyChain(for: tokenType.rawValue, account: school.name) {
                do {
                    return try decoder.decode(Token.self, from: data)
                } catch {
                    return nil
                }
            }
        }
        return nil
    }
    
    private func getUser() -> TumbleUser? {
        do {
            if let school = self.getDefaultSchool() {
                if let data = self.keychainManager.readKeyChain(for: "tumble-user", account: school.name) {
                    let user = try decoder.decode(TumbleUser.self, from: data)
                    return TumbleUser(username: user.username, password: user.password, name: user.name)
                }
            }
            return nil
        } catch {
            AppLogger.shared.debug("No available user to decode")
            return nil
        }
    }
    
    private func setUser(newValue: TumbleUser?) -> Void {
        do {
            let data = try encoder.encode(newValue)
            if let school = self.getDefaultSchool() {
                self.keychainManager.saveKeyChain(data, for: "tumble-user", account: school.name, completion: { result in
                    switch result {
                    case .success:
                        AppLogger.shared.debug("Updated user in keychain")
                    case .failure:
                        AppLogger.shared.critical("Failed to update user in keychain")
                    }
                })
            }
        } catch {
            AppLogger.shared.critical("Encoding error")
        }
    }
    
    private func setToken(newValue: Token?, tokenType: TokenType) -> Void {
        if let school = self.getDefaultSchool() {
            if newValue != nil {
                do {
                    let storedData = try encoder.encode(newValue)
                    self.keychainManager.saveKeyChain(storedData, for: tokenType.rawValue, account: school.name) { result in
                        switch result {
                        case .success(_):
                            AppLogger.shared.debug("Successfully stored \(tokenType.rawValue)")
                        case .failure(_):
                            AppLogger.shared.critical("Failed to store \(tokenType.rawValue)")
                        }
                    }
                } catch {
                    AppLogger.shared.critical("Failed to store \(tokenType.rawValue) object")
                }
                
            } else {
                self.keychainManager.deleteKeyChain(for: tokenType.rawValue, account: school.name, completion: { result in
                    switch result {
                    case .success(_):
                        AppLogger.shared.debug("Successfully deleted \(tokenType.rawValue)")
                    case .failure(_):
                        AppLogger.shared.critical("Failed to delete \(tokenType.rawValue)")
                    }
                })
            }
        }
    }
}
