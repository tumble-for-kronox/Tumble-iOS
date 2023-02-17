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
    private let encoder = JSONEncoder()
    private let decoder = JSONDecoder()
    
    init() {
        serialQueue.maxConcurrentOperationCount = 1
        serialQueue.qualityOfService = .userInitiated
        
        let config: URLSessionConfiguration = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = 20
        config.timeoutIntervalForResource = 20
        
        self.urlSession = URLSession(configuration: config)
    }
    
    
    var sessionToken: Token? {
        get {
            getToken(tokenType: .sessionToken)
        }
        set {
            setToken(newValue: newValue, tokenType: .sessionToken)
        }
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
    
    /**
        This method will clear all tokens both from memory and persistent storage.
        Most common use case for this method is user logout.
    */
    func logOutUser(completionHandler: ((Result<Int, Error>) -> Void)? = nil) {
        if OperationQueue.current == serialQueue {
            self.clearTokensAndKeyChain(completionHandler: completionHandler)
        } else {
            serialQueue.addOperation {
                self.clearTokensAndKeyChain(completionHandler: completionHandler)
            }
        }
    }
}




// Private methods with specific functions in file
extension AuthManager {
    
    private func clearTokensAndKeyChain(completionHandler: ((Result<Int, Error>) -> Void)? = nil) {
        sessionToken = nil
        refreshToken = nil
        clearKeyChain(completionHandler: completionHandler)
    }
    
    
    private func clearKeyChain(completionHandler: ((Result<Int, Error>) -> Void)?) {
        if let school = self.getDefaultSchool() {
            self.deleteKeyChain(for: TokenType.refreshToken.rawValue, account: school.name, completion: { result in
                switch result {
                case .success(_):
                    AppLogger.shared.info("Successfully cleared keychain for refresh-token")
                    self.deleteKeyChain(for: TokenType.sessionToken.rawValue, account: school.name, completion: { result in
                        switch result {
                        case .success(_):
                            AppLogger.shared.info("Successfully cleared keychain of session-token")
                            self.deleteKeyChain(for: "tumble-user", account: school.name, completion: { result in
                                switch result {
                                case .success(_):
                                    AppLogger.shared.info("Successfully cleared keychain of user")
                                    completionHandler?(.success(3))
                                case .failure(let failure):
                                    AppLogger.shared.info("Failed to clear keychain -> \(failure.localizedDescription)")
                                    completionHandler?(.failure(.internal(reason: "Failed to modify keychain for value 'session-token'")))
                                }
                            })
                        case .failure(let failure):
                            AppLogger.shared.info("Failed to clear keychain -> \(failure.localizedDescription)")
                            completionHandler?(.failure(.internal(reason: "Failed to modify keychain for value 'session-token'")))
                        }
                    })
                case .failure(let failure):
                    AppLogger.shared.info("Failed to clear keychain -> \(failure.localizedDescription)")
                    completionHandler?(.failure(.internal(reason: "Failed to modify keychain for value 'refresh-token'")))
                }
            })
        }
    }
    
    private func processAutoLoginWithKeyChainCredentials(completionHandler: @escaping (Result<TumbleUser, Error>) -> Void) -> Void {
        if let school = self.getDefaultSchool(), let user = self.user {
            var urlRequest = URLRequest(url: Endpoint.login(schoolId: String(school.id)).url)
            urlRequest.httpMethod = Method.get.rawValue
            urlRequest.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
            urlRequest.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Accept")
            
            do {
                let userRequest = Request.KronoxUserLogin(username: user.username, password: user.password)
                urlRequest.httpBody = try encoder.encode(userRequest)
            } catch let err {
                AppLogger.shared.info("Failed to encode JSON body of type \(user.self)")
                completionHandler(.failure(.internal(reason: "\(err)")))
            }
            
            urlSession.dataTask(with: urlRequest, completionHandler: { data, response, error in
                self.handleAuthResponse(
                    data: data,
                    response: response,
                    error: error as? Error,
                    completionHandler: completionHandler)
            }).resume()
        } else {
            completionHandler(.failure(.generic(reason: "No school selected or no refresh token available")))
        }
    }
    
    private func processLogin(user: Request.KronoxUserLogin, completionHandler: @escaping (Result<TumbleUser, Error>) -> Void) {
        if let school = self.getDefaultSchool() {
            var urlRequest = URLRequest(url: Endpoint.login(schoolId: String(school.id)).url)
            urlRequest.httpMethod = Method.post.rawValue
            urlRequest.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
            urlRequest.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Accept")
            do {
                urlRequest.httpBody = try encoder.encode(user)
            } catch let err {
                AppLogger.shared.info("Failed to encode JSON body of type \(user.self)")
                completionHandler(.failure(.internal(reason: "\(err)")))
            }
            urlSession.dataTask(with: urlRequest, completionHandler: { data, response, error in
                self.handleAuthResponse(
                    password: user.password,
                    data: data,
                    response: response,
                    error: error as? Error,
                    completionHandler: completionHandler)
            }).resume()
        } else {
            completionHandler(.failure(.generic(reason: "No school selected")))
        }
    }
    
    private func processAutoLogin(completionHandler: @escaping (Result<TumbleUser, Error>) -> Void) -> Void {
        
        // If there is a school selected and an available refresh token
        if let school = self.getDefaultSchool(), let token = self.refreshToken {
            var urlRequest = URLRequest(url: Endpoint.users(schoolId: String(school.id)).url)
            urlRequest.httpMethod = Method.get.rawValue
            urlRequest.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
            urlRequest.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Accept")
            urlRequest.setValue(token.value, forHTTPHeaderField: "X-auth-token")
                            
            urlSession.dataTask(with: urlRequest, completionHandler: { data, response, error in
                self.handleAuthResponse(
                    data: data,
                    response: response,
                    error: error as? Error,
                    completionHandler: { (result: Result<TumbleUser, Error>) in
                    switch result {
                    case .success(let user):
                        completionHandler(.success(user))
                    case .failure(let failure):
                        AppLogger.shared.info("Missing refresh token or is expired -> \(failure)")
                        self.processAutoLoginWithKeyChainCredentials(completionHandler: completionHandler)
                    }
                })
            }).resume()
        } else {
            completionHandler(.failure(.generic(reason: "No school selected or no refresh token available. Attempting credential login")))
            self.processAutoLoginWithKeyChainCredentials(completionHandler: completionHandler)
        }
    }
    
    private func handleAuthResponse(
        password: String? = nil,
        data: Data?, response: URLResponse?,
        error: Error?,
        completionHandler: @escaping (Result<TumbleUser, Error>) -> Void) {
            if let data = data, let result = try? self.decoder.decode(Response.KronoxUser.self, from: data) {
                self.refreshToken = Token(value: result.refreshToken, createdDate: Date.now)
                self.sessionToken = Token(value: result.sessionToken, createdDate: Date.now)
                
                // Replace old user with new user
                // if the call instance contains a given password.
                // In any other case, we will have a stored user in
                // the keychain already.
                if let password = password {
                    let newUser = TumbleUser(username: result.username, password: password, name: result.name)
                    AppLogger.shared.info("Registering new user \(result.username)")
                    self.user = newUser
                    completionHandler(.success(newUser))
                } else if let user = self.user {
                    completionHandler(.success(user))
                }
                
            } else if let statusCode = (response as? HTTPURLResponse)?.statusCode, statusCode > 299 {
                // In case we got an error while using refresh token, we want to clear token storage - there's no way
                // to recover from this
                clearTokensAndKeyChain()
                completionHandler(.failure(.generic(reason: "Could not retrieve any tokens")))

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
            if let data = self.readKeyChain(for: tokenType.rawValue, account: school.name) {
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
                if let data = self.readKeyChain(for: "tumble-user", account: school.name) {
                    let user = try decoder.decode(TumbleUser.self, from: data)
                    return TumbleUser(username: user.username, password: user.password, name: user.name)
                }
            }
            return nil
        } catch {
            AppLogger.shared.info("No available user to decode")
            return nil
        }
    }
    
    private func setUser(newValue: TumbleUser?) -> Void {
        do {
            let data = try encoder.encode(newValue)
            if let school = self.getDefaultSchool() {
                self.saveKeyChain(data, for: "tumble-user", account: school.name, completion: { result in
                    switch result {
                    case .success(_):
                        AppLogger.shared.info("Updated user in keychain")
                    case .failure(_):
                        AppLogger.shared.info("Failed to update user in keychain")
                    }
                })
            }
        } catch {
            AppLogger.shared.info("Encoding error")
        }
    }
    
    private func setToken(newValue: Token?, tokenType: TokenType) -> Void {
        if let school = self.getDefaultSchool() {
            if newValue != nil {
                do {
                    let storedData = try encoder.encode(newValue)
                    self.saveKeyChain(storedData, for: tokenType.rawValue, account: school.name) { result in
                        switch result {
                        case .success(_):
                            AppLogger.shared.info("Successfully stored \(tokenType.rawValue)")
                        case .failure(_):
                            AppLogger.shared.info("Failed to store \(tokenType.rawValue)")
                        }
                    }
                } catch {
                    AppLogger.shared.info("Failed to store \(tokenType.rawValue) object")
                }
                
            } else {
                self.deleteKeyChain(for: tokenType.rawValue, account: school.name, completion: { result in
                    switch result {
                    case .success(_):
                        AppLogger.shared.info("Successfully deleted \(tokenType.rawValue)")
                    case .failure(_):
                        AppLogger.shared.info("Failed to delete \(tokenType.rawValue)")
                    }
                })
            }
        }
    }
    
    private func updateKeyChain(_ data: Data, for service: String, account: String, completion: @escaping (Result<Bool, Error>) -> Void) {
        let query = [
                kSecClass: kSecClassGenericPassword,
                kSecAttrService: service,
                kSecAttrAccount: account
            ] as CFDictionary

            let attributes = [
                kSecValueData: data
            ] as CFDictionary

        let status = SecItemUpdate(query, attributes)
        guard status == errSecSuccess else {
            completion(.failure(.internal(reason: status.description)))
            return
        }
        completion(.success(true))
    }
    
    
    private func deleteKeyChain(for service: String, account: String, completion: @escaping (Result<Bool, Error>) -> Void) {
        
        let query = [
            kSecAttrService: service,
            kSecAttrAccount: account,
            kSecClass: kSecClassGenericPassword,
            ] as CFDictionary
        
        // Delete item from keychain
        SecItemDelete(query)
        AppLogger.shared.info("Deleted item from keychain")
        completion(.success(true))
    }
    
    private func readKeyChain(for service: String, account: String) -> Data? {
        let query = [
            kSecAttrService: service,
            kSecAttrAccount: account,
            kSecClass: kSecClassGenericPassword,
            kSecReturnData: true
        ] as CFDictionary
        
        var result: AnyObject?
        SecItemCopyMatching(query, &result)
        
        guard let data = result as? Data else {
            return nil
        }
        return data
    }
    
    private func saveKeyChain(_ data: Data, for service: String, account: String, completion: @escaping (Result<Bool, Error>) -> Void) {
        
        let query = [
            kSecValueData: data,
            kSecClass: kSecClassGenericPassword,
            kSecAttrService: service,
            kSecAttrAccount: account,
        ] as CFDictionary
        
        // Add data in query to keychain
        let status = SecItemAdd(query, nil)
        
        if status == errSecDuplicateItem {
            updateKeyChain(data, for: service, account: account, completion: completion)
            return
        }
        
        if status != errSecSuccess {
            AppLogger.shared.info("Could not save item to keychain -> \(status)")
            completion(.failure(.internal(reason: status.description)))
            return
        }
        
        AppLogger.shared.info("Added item to keychain")
        completion(.success(true))
    }
}
