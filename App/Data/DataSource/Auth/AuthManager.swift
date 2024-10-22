//
//  AuthManager.swift
//  Tumble
//
//  Created by Adis Veletanlic on 2023-02-13.
//

import Foundation

class AuthManager {
    private let urlRequestUtils = NetworkUtilities.shared
    private let keychainManager = KeyChainManager()
    private let urlSession: URLSession = URLSession.shared
    private let networkController: NetworkController = .shared
    
    enum AuthError: Swift.Error {
        case autoLoginError(user: TumbleUser)
        case httpResponseError
        case tokenError
        case decodingError
        case requestError
    }

    func loginUser(authSchoolId: Int, user: NetworkRequest.KronoxUserLogin) async throws -> TumbleUser {
        let urlRequest = try createLoginRequest(authSchoolId: authSchoolId, user: user)
        return try await performLoginRequest(urlRequest, with: user)
    }
    
    func logOutUser() async throws {
        AppLogger.shared.debug("Logging out user")
        try await clearKeychainData(for: [TokenType.refreshToken.rawValue, TokenType.sessionDetails.rawValue, "tumble-user"])
    }

    func autoLoginUser(authSchoolId: Int) async throws -> TumbleUser {
        guard let user = await getUser() else {
            throw AuthError.decodingError
        }
        let refreshToken = await getToken(.refreshToken)
        let sessionDetails = await getToken(.sessionDetails)
        
        let urlRequest = try createAutoLoginRequest(authSchoolId: authSchoolId, refreshToken: refreshToken, sessionDetails: sessionDetails)
        
        return try await performAutoLoginRequest(urlRequest, with: user)
    }

    // MARK: - Private Methods

    private func createLoginRequest(authSchoolId: Int, user: NetworkRequest.KronoxUserLogin) throws -> URLRequest {
        return try urlRequestUtils.createTumbleUrlRequest(
            method: .post,
            endpoint: .login(schoolId: String(authSchoolId)),
            body: user
        )
    }

    private func performLoginRequest(_ urlRequest: URLRequest, with user: NetworkRequest.KronoxUserLogin) async throws -> TumbleUser {
        let (data, response) = try await urlSession.data(for: urlRequest)
        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
            throw AuthError.httpResponseError
        }
        
        try await storeUpdatedTokensIfNeeded(from: httpResponse)
        let kronoxUser = try decodeKronoxUser(from: data)

        return TumbleUser(username: kronoxUser.username, name: kronoxUser.name)
    }

    private func performAutoLoginRequest(_ urlRequest: URLRequest, with user: TumbleUser) async throws -> TumbleUser {
        do {
            let (data, response) = try await urlSession.data(for: urlRequest)
            
            if let statusCode = (response as? HTTPURLResponse)?.statusCode, statusCode > 299 {
                try await logOutUser()
                throw AuthError.httpResponseError
            }

            try await storeUpdatedTokensIfNeeded(from: response as? HTTPURLResponse)
            let kronoxUser = try decodeKronoxUser(from: data)

            return TumbleUser(username: user.username, name: kronoxUser.name)
        } catch {
            if networkController.connected {
                try await logOutUser()
                throw AuthError.requestError
            }
            throw AuthError.autoLoginError(user: user) /// Show latest stored user info
        }
    }

    private func storeUpdatedTokensIfNeeded(from httpResponse: HTTPURLResponse?) async throws {
        if let refreshToken = httpResponse?.allHeaderFields["x-auth-token"] as? String,
           let sessionDetails = httpResponse?.allHeaderFields["x-session-token"] as? String {
            try await setToken(Token(value: refreshToken, createdDate: Date.now), for: .refreshToken)
            try await setToken(Token(value: sessionDetails, createdDate: Date.now), for: .sessionDetails)
        } else {
            AppLogger.shared.debug("No new tokens in call or token could not be stored")
        }
    }

    private func decodeKronoxUser(from data: Data) throws -> Response.KronoxUser {
        let decoder = JSONDecoder()
        guard let result = try? decoder.decode(Response.KronoxUser.self, from: data) else {
            AppLogger.shared.debug("Could not decode user. Data is: \(data)")
            throw AuthError.decodingError
        }
        return result
    }

    private func createAutoLoginRequest(authSchoolId: Int, refreshToken: Token? = nil, sessionDetails: Token? = nil) throws -> URLRequest {
        return try urlRequestUtils.createTumbleUrlRequest(
            method: .get,
            endpoint: .users(schoolId: String(authSchoolId)),
            refreshToken: refreshToken?.value,
            sessionDetails: sessionDetails?.value,
            body: nil as String?
        )
    }

    private func clearKeychainData(for keys: [String]) async throws {
        for key in keys {
            try await keychainManager.deleteKeyChain(for: key, account: "Tumble for Kronox")
        }
    }

    // MARK: - Keychain Management

    func getUser() async -> TumbleUser? {
        guard let data = try? await keychainManager.readKeyChain(for: "tumble-user", account: "Tumble for Kronox"),
              let user = try? JSONDecoder().decode(TumbleUser.self, from: data) else {
            AppLogger.shared.debug("Could not decode Tumble user")
            return nil
        }
        return user
    }

    func getToken(_ tokenType: TokenType) async -> Token? {
        guard let data = try? await keychainManager.readKeyChain(for: tokenType.rawValue, account: "Tumble for Kronox"),
              let token = try? JSONDecoder().decode(Token.self, from: data) else {
            AppLogger.shared.error("Could not retrieve token")
            return nil
        }
        AppLogger.shared.debug("Token is \(token.value)")
        return token
    }

    func setUser(_ newValue: TumbleUser?) async throws {
        guard let newValue = newValue, let data = try? JSONEncoder().encode(newValue) else { return }
        try await keychainManager.saveKeyChain(data, for: "tumble-user", account: "Tumble for Kronox")
    }

    func setToken(_ newValue: Token?, for tokenType: TokenType) async throws {
        guard let newValue = newValue, let data = try? JSONEncoder().encode(newValue) else { return }
        try await keychainManager.saveKeyChain(data, for: tokenType.rawValue, account: "Tumble for Kronox")
    }
}
