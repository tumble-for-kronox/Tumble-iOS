//
//  AuthManager.swift
//  Tumble
//
//  Created by Adis Veletanlic on 2023-02-13.
//

import Foundation

class AuthManager: AuthManagerProtocol {
    private let serialQueue = OperationQueue()
    
    let urlRequestUtils = NetworkUtilities.shared
    let keychainManager = KeyChainManager()
    let urlSession: URLSession
    
    init() {
        // Limit amount of concurrent operations to avoid
        // potentially strange state behavior
        serialQueue.maxConcurrentOperationCount = 1
        serialQueue.qualityOfService = .userInitiated
        urlSession = URLSession.shared
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
    
    func autoLoginUser(
        authSchoolId: Int,
        completionHandler: @escaping (Result<TumbleUser, Error>) -> Void
    ) {
        serialQueue.addOperation {
            let semaphore = DispatchSemaphore(value: 0)
            AppLogger.shared.debug("Running auto login ...")
            self.processAutoLogin(
                authSchoolId: authSchoolId,
                completionHandler: { (result: Result<TumbleUser, Error>) in
                    completionHandler(result)
                    semaphore.signal()
                }
            )
            _ = semaphore.wait(timeout: DispatchTime.distantFuture)
        }
    }
    
    func loginUser(
        authSchoolId: Int,
        user: Request.KronoxUserLogin,
        completionHandler: @escaping (Result<TumbleUser, Error>) -> Void
    ) {
        // Process all token requests using private serial queue to avoid issues with race conditions
        // when multiple credentials / login requests can lead auth manager in an unpredictable state
        serialQueue.addOperation {
            let semaphore = DispatchSemaphore(value: 0)
            
            self.processLogin(
                authSchoolId: authSchoolId,
                user: user,
                completionHandler: { (result: Result<TumbleUser, Error>) in
                    completionHandler(result)
                    semaphore.signal()
                }
            )
            _ = semaphore.wait(timeout: DispatchTime.distantFuture)
        }
    }
    
    // This method will clear all tokens both from memory and persistent storage.
    // Most common use case for this method is user logout.
    func logOutUser(completionHandler: ((Result<Int, Error>) -> Void)? = nil) {
        if OperationQueue.current == serialQueue {
            clearTokensAndKeyChain(of: [TokenType.refreshToken.rawValue, "tumble-user"], completionHandler: completionHandler)
        } else {
            serialQueue.addOperation {
                self.clearTokensAndKeyChain(of: [TokenType.refreshToken.rawValue, "tumble-user"], completionHandler: completionHandler)
            }
        }
    }
}
