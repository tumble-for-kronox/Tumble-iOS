//
//  AuthManager.swift
//  tumble-ios
//
//  Created by Adis Veletanlic on 2023-02-13.
//

import Foundation


class AuthManager {

    
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
    
    
    private var sessionToken: String? {
        get {
            if let school = self.getDefaultSchool() {
                if let data = self.readKeyChain(for: "tumble-user", account: school.name) {
                    return String(data: data, encoding: .utf8)
                }
            }
            return nil
        }
        set {
            if let school = self.getDefaultSchool() {
                if let value = newValue {
                    self.saveKeyChain((value.data(using: .utf8))!, for: "session-token", account: school.name) { result in
                        switch result {
                        case .success(_):
                            AppLogger.shared.info("Successfully stored session-token")
                        case .failure(_):
                            AppLogger.shared.info("Failed to store session-token")
                        }
                    }
                } else {
                    self.deleteKeyChain(for: "session-token", account: school.name, completion: { result in
                        switch result {
                        case .success(_):
                            AppLogger.shared.info("Successfully deleted session-token")
                        case .failure(_):
                            AppLogger.shared.info("Failed to delete session-token")
                        }
                    })
                }
            }
        }
    }
    
    var refreshToken: String? {
        get {
            if let school = self.getDefaultSchool() {
                if let data = self.readKeyChain(for: "refresh-token", account: school.name) {
                    return String(data: data, encoding: .utf8)
                }
            }
            return nil
        }
        set {
            if let school = self.getDefaultSchool() {
                if let value = newValue {
                    self.saveKeyChain((value.data(using: .utf8))!, for: "refresh-token", account: school.name) { result in
                        switch result {
                        case .success(_):
                            AppLogger.shared.info("Successfully stored refresh-token")
                        case .failure(_):
                            AppLogger.shared.info("Failed to store refresh-token")
                        }
                    }
                } else {
                    self.deleteKeyChain(for: "refresh-token", account: school.name, completion: { result in
                        switch result {
                        case .success(_):
                            AppLogger.shared.info("Successfully deleted refresh-token")
                        case .failure(_):
                            AppLogger.shared.info("Failed to delete refresh-token")
                        }
                    })
                }
            }
        }
    }
    
    public var user: TumbleUser? {
        get {
            do {
                if let school = self.getDefaultSchool() {
                    if let data = self.readKeyChain(for: "tumble-user", account: school.name) {
                        let user = try decoder.decode(TumbleUser.self, from: data)
                        return TumbleUser(username: user.username, name: user.name)
                    }
                }
                return nil
            } catch {
                AppLogger.shared.info("No available user to decode")
                return nil
            }
        }
        set {
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
    }
    
    private func clearTokensAndKeyChain(completionHandler: ((Result<Int, Error>) -> Void)? = nil) {
        sessionToken = nil
        refreshToken = nil
        clearKeyChain(completionHandler: completionHandler)
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
    
    private func clearKeyChain(completionHandler: ((Result<Int, Error>) -> Void)?) {
        if let school = self.getDefaultSchool() {
            self.deleteKeyChain(for: "refresh-token", account: school.name, completion: { result in
                switch result {
                case .success(_):
                    AppLogger.shared.info("Successfully cleared keychain for refresh-token")
                    self.deleteKeyChain(for: "session-token", account: school.name, completion: { result in
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
    
    func autoLoginUser(completionHandler: @escaping (Result<Response.KronoxUser, Error>) -> Void) -> Void {
        serialQueue.addOperation {
            let semaphore = DispatchSemaphore(value: 0)
            
            self.processAutoLogin(completionHandler: { (result: Result<Response.KronoxUser, Error>) in
                completionHandler(result)
                semaphore.signal()
            })
            _ = semaphore.wait(timeout: DispatchTime.distantFuture)
        }
    }
    
    
    func loginUser(user: Request.KronoxUserLogin, completionHandler: @escaping (Result<Response.KronoxUser, Error>) -> Void) {
        // Process all token requests using private serial queue to avoid issues with race conditions
        // when multiple credentials / login requests can lead auth manager in an unpredictable state
        serialQueue.addOperation {
            let semaphore = DispatchSemaphore(value: 0)
            
            self.processLogin(user: user, completionHandler: { (result: Result<Response.KronoxUser, Error>) in
                completionHandler(result)
                semaphore.signal()
            })
            _ = semaphore.wait(timeout: DispatchTime.distantFuture)
        }
    }
    
    
    private func processLogin(user: Request.KronoxUserLogin, completionHandler: @escaping (Result<Response.KronoxUser, Error>) -> Void) {
        
        if let school = self.getDefaultSchool() {
            do {
                var urlRequest = URLRequest(url: Endpoint.login(schoolId: String(school.id)).url)
                urlRequest.httpMethod = Method.post.rawValue
                urlRequest.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
                urlRequest.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Accept")
                
                urlRequest.httpBody = try encoder.encode(user)
                
                urlSession.dataTask(with: urlRequest, completionHandler: { data, response, error in
                    self.handleAuthResponse(data: data, response: response, error: error as? Error, completionHandler: completionHandler)
                }).resume()
            } catch {
                AppLogger.shared.info("Failed to encode JSON body of type \(user.self)")
                completionHandler(.failure(.generic(reason: "Failed to encode JSON body of type \(user.self)")))
            }
        } else {
            completionHandler(.failure(.generic(reason: "No school selected")))
        }
    }
    
    private func processAutoLogin(completionHandler: @escaping (Result<Response.KronoxUser, Error>) -> Void) -> Void {
        if let school = self.getDefaultSchool(), let token = self.refreshToken {
            var urlRequest = URLRequest(url: Endpoint.users(schoolId: String(school.id)).url)
            urlRequest.httpMethod = Method.get.rawValue
            urlRequest.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
            urlRequest.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Accept")
            urlRequest.setValue(token, forHTTPHeaderField: "X-auth-token")
                            
            urlSession.dataTask(with: urlRequest, completionHandler: { data, response, error in
                self.handleAuthResponse(data: data, response: response, error: error as? Error, completionHandler: completionHandler)
            }).resume()
        } else {
            completionHandler(.failure(.generic(reason: "No school selected")))
        }
    }
    
    private func handleAuthResponse(data: Data?, response: URLResponse?, error: Error?, completionHandler: @escaping (Result<Response.KronoxUser, Error>) -> Void) {
        if let data = data, let result = try? self.decoder.decode(Response.KronoxUser.self, from: data) {
            self.refreshToken = result.refreshToken
            self.sessionToken = result.sessionToken
            
            if let school = self.getDefaultSchool() {
                if let data = self.readKeyChain(for: "tumble-user", account: school.name) {
                    if let user = try? decoder.decode(TumbleUser.self, from: data) {
                        AppLogger.shared.info("\(self.user.debugDescription)")
                        self.user = user
                    }
                }
            }
            
            completionHandler(.success(result))
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
        
        //return String(data: data, encoding: .utf8)!
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
