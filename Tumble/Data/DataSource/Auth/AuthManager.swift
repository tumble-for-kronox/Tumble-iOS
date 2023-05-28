//
//  AuthManager.swift
//  Tumble
//
//  Created by Adis Veletanlic on 2023-02-13.
//

import Foundation

class AuthManager {
    let urlRequestUtils = NetworkUtilities.shared
    let keychainManager = KeyChainManager()
    let urlSession: URLSession = URLSession.shared
    
    func autoLoginUser(authSchoolId: Int) async throws -> TumbleUser {
        return try await processAutoLogin(authSchoolId: authSchoolId)
    }
    
    func loginUser(authSchoolId: Int, user: Request.KronoxUserLogin) async throws -> TumbleUser {
        return try await processLogin(authSchoolId: authSchoolId, user: user)
    }
    
    func logOutUser() async throws {
        try await clearTokensAndKeyChain(of: [TokenType.refreshToken.rawValue, "tumble-user"])
    }
    
    private func clearTokensAndKeyChain(of tokensToDelete: [String]) async throws {
        do {
            try await clearKeyChain(of: tokensToDelete)
        } catch (let error) {
            AppLogger.shared.critical("Failed to delete tokens: \(error)")
            throw error
        }
    }
    
    // This method will clear all tokens both from memory and persistent storage.
    // Most common use case for this method is user logout.
    private func clearKeyChain(of tokensToDelete: [String]) async throws -> Void {
        for token in tokensToDelete {
            try await keychainManager.deleteKeyChain(for: token, account: "Tumble for Kronox")
        }
    }

    /// Attempts to log in a user with credentials that are stored
    /// in keychain and have been previously saved
    private func processAutoLoginWithKeyChainCredentials(authSchoolId: Int) async throws -> TumbleUser {
        let user = await getUser()
        if let user = user {
            let userRequest = Request.KronoxUserLogin(username: user.username, password: user.password)
            AppLogger.shared.debug(
                "Running login with keychain credentials for user: \(userRequest.username)",
                source: "AuthManager"
            )
            guard let urlRequest = urlRequestUtils.createUrlRequest(
                method: .post,
                endpoint: .login(schoolId: String(authSchoolId)),
                body: userRequest
            ) else {
                AppLogger.shared.critical("Could not create URLRequest object")
                throw Error.generic(reason: "Could not create URLRequest object")
            }
            
            do {
                let decoder = JSONDecoder()
                let (data, _) = try await urlSession.data(for: urlRequest)
                guard let result = try? decoder.decode(Response.KronoxUser.self, from: data) else {
                    throw Error.generic(reason: "Could not decode object to KronoxUser")
                }
                
                try await setToken(newValue: Token(value: result.refreshToken, createdDate: Date.now), tokenType: .refreshToken)
                
                return TumbleUser(username: user.username, password: user.password, name: user.name)
            } catch {
                throw Error.generic(reason: "Could not decode object to KronoxUser")
            }
            
        } else {
            AppLogger.shared.critical("Missing school/keychain user ...")
            throw Error.internal(reason: "No user available")
        }
    }
    
    // Function to log in user with credentials passed
    // from account page when entered credentials. On successful response,
    // the user is stored securely in the keychain as TumbleUser
    private func processLogin(authSchoolId: Int, user: Request.KronoxUserLogin) async throws -> TumbleUser {
        guard let urlRequest = urlRequestUtils.createUrlRequest(
            method: .post,
            endpoint: .login(schoolId: String(authSchoolId)),
            body: user
        ) else {
            throw Error.generic(reason: "Could not create URLRequest object")
        }
        
        do {
            let decoder = JSONDecoder()
            let (data, _) = try await urlSession.data(for: urlRequest)
            guard let result = try? decoder.decode(Response.KronoxUser.self, from: data) else {
                throw Error.generic(reason: "Could not decode object to KronoxUser")
            }
            
            try await setToken(newValue: Token(value: result.refreshToken, createdDate: Date.now), tokenType: .refreshToken)
            try await setUser(newValue: TumbleUser(username: result.username, password: user.password, name: result.name))
            
            return TumbleUser(username: user.username, password: user.password, name: result.name)
        } catch (let error) {
            throw error
        }
    }
    
    private func processAutoLogin(authSchoolId: Int) async throws -> TumbleUser {
        
        guard let token = await getToken(tokenType: .refreshToken),
              let user = await getUser() else {
            try await logOutUser()
            throw Error.internal(reason: "No refresh token or user stored")
        }
        
        guard let urlRequest = urlRequestUtils.createUrlRequest(
            method: .get,
            endpoint: .users(schoolId: String(authSchoolId)),
            refreshToken: token.value
        ) else {
            return try await processAutoLoginWithKeyChainCredentials(authSchoolId: authSchoolId)
        }
        
        do {
            let decoder = JSONDecoder()
            let (data, response) = try await urlSession.data(for: urlRequest)
            
            if let statusCode = (response as? HTTPURLResponse)?.statusCode {
                if statusCode > 299 {
                   return try await processAutoLoginWithKeyChainCredentials(authSchoolId: authSchoolId)
                }
            }
            
            guard let result = try? decoder.decode(Response.KronoxUser.self, from: data) else {
                throw Error.generic(reason: "Could not decode object to KronoxUser")
            }
            
            try await setToken(newValue: Token(value: result.refreshToken, createdDate: Date.now), tokenType: .refreshToken)
            
            return TumbleUser(username: user.username, password: user.password, name: result.name)
        } catch (let error) {
            throw error
        }
    }
    
    func getToken(tokenType: TokenType) async -> Token? {
        do {
            guard let data = try await keychainManager.readKeyChain(for: tokenType.rawValue, account: "Tumble for Kronox") else {
                AppLogger.shared.critical("Token is nil")
                return nil
            }
            let decoder = JSONDecoder()
            let token = try decoder.decode(Token.self, from: data)
            return token
        } catch {
            AppLogger.shared.critical("Could not decode token")
            return nil
        }
    }
    
    func getUser() async -> TumbleUser? {
        do {
            guard let data = try await keychainManager.readKeyChain(for: "tumble-user", account: "Tumble for Kronox") else {
                AppLogger.shared.critical("User is nil")
                return nil
            }
            let decoder = JSONDecoder()
            let user = try decoder.decode(TumbleUser.self, from: data)
            return TumbleUser(username: user.username, password: user.password, name: user.name)
        } catch (let error) {
            AppLogger.shared.debug("No available user to decode: \(error)")
            return nil
        }
    }
    
    func setUser(newValue: TumbleUser?) async throws {
        let encoder = JSONEncoder()
        let data = try encoder.encode(newValue)
        try await keychainManager.saveKeyChain(data, for: "tumble-user", account: "Tumble for Kronox")
    }
    
    func setToken(newValue: Token?, tokenType: TokenType) async throws {
        let encoder = JSONEncoder()
        let storedData = try encoder.encode(newValue)
        try await keychainManager.saveKeyChain(storedData, for: tokenType.rawValue, account: "Tumble for Kronox")
    }
}
