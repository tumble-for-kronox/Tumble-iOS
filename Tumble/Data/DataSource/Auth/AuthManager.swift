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
    
    enum AuthError: Swift.Error {
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
        AppLogger.shared.info("Logging out user")
        try await clearKeychainData(for: [TokenType.refreshToken.rawValue, TokenType.sessionToken.rawValue, "tumble-user"])
    }

    func autoLoginUser(authSchoolId: Int) async throws -> TumbleUser {
        guard let refreshToken = await getToken(.refreshToken),
              let sessionToken = await getToken(.sessionToken),
              let user = await getUser() else {
            throw AuthError.tokenError
        }
        let urlRequest = try createAutoLoginRequest(authSchoolId: authSchoolId, refreshToken: refreshToken, sessionToken: sessionToken)
        return try await performAutoLoginRequest(urlRequest, with: user)
    }

    // MARK: - Private Methods

    private func createLoginRequest(authSchoolId: Int, user: NetworkRequest.KronoxUserLogin) throws -> URLRequest {
        return try urlRequestUtils.createUrlRequest(
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

        let kronoxUser = try decodeKronoxUser(from: data)
        try await storeTokens(from: kronoxUser)

        return TumbleUser(username: user.username, name: kronoxUser.name)
    }

    private func performAutoLoginRequest(_ urlRequest: URLRequest, with user: TumbleUser) async throws -> TumbleUser {
        let (data, response) = try await urlSession.data(for: urlRequest)
        if let statusCode = (response as? HTTPURLResponse)?.statusCode, statusCode > 299 {
            try await logOutUser()
            throw AuthError.httpResponseError
        }

        try await storeUpdatedTokensIfNeeded(from: response as? HTTPURLResponse)
        let kronoxUser = try decodeKronoxUser(from: data)

        return TumbleUser(username: user.username, name: kronoxUser.name)
    }

    private func storeUpdatedTokensIfNeeded(from httpResponse: HTTPURLResponse?) async throws {
        if let refreshToken = httpResponse?.allHeaderFields["X-auth-header"] as? String {
            try await setToken(Token(value: refreshToken, createdDate: Date.now), for: .refreshToken)
        }
        if let sessionTokenJson = httpResponse?.allHeaderFields["X-session-token"] as? String,
           let sessionDetails = try? JSONDecoder().decode(NetworkRequest.SessionDetails.self, from: Data(sessionTokenJson.utf8)) {
            try await setToken(Token(value: sessionDetails.sessionToken, createdDate: Date.now), for: .sessionToken)
        }
    }

    private func decodeKronoxUser(from data: Data) throws -> NetworkResponse.KronoxUser {
        let decoder = JSONDecoder()
        guard let result = try? decoder.decode(NetworkResponse.KronoxUser.self, from: data) else {
            throw AuthError.decodingError
        }
        return result
    }

    private func storeTokens(from kronoxUser: NetworkResponse.KronoxUser) async throws {
        try await setToken(Token(value: kronoxUser.refreshToken, createdDate: Date.now), for: .refreshToken)
        try await setToken(Token(value: kronoxUser.sessionDetails.sessionToken, createdDate: Date.now), for: .sessionToken)
    }

    private func createAutoLoginRequest(authSchoolId: Int, refreshToken: Token, sessionToken: Token) throws -> URLRequest {
        return try urlRequestUtils.createUrlRequest(
            method: .get,
            endpoint: .users(schoolId: String(authSchoolId)),
            refreshToken: refreshToken.value,
            sessionToken: sessionToken.value,
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
            return nil
        }
        return user
    }

    func getToken(_ tokenType: TokenType) async -> Token? {
        guard let data = try? await keychainManager.readKeyChain(for: tokenType.rawValue, account: "Tumble for Kronox"),
              let token = try? JSONDecoder().decode(Token.self, from: data) else {
            return nil
        }
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
