//
//  UserModel.swift
//  Tumble
//
//  Created by Adis Veletanlic on 2023-02-13.
//

import Foundation
import SwiftUI

/// Controller handling any changes to the specific user
/// currently authorized in the application. Also attempts
/// to authorize the session on startup.
final class UserController: ObservableObject {
    @Inject var authManager: AuthManager
    @Inject var kronoxManager: KronoxManager
    @Inject var preferenceService: PreferenceService
    
    @Published var authStatus: AuthStatus = .unAuthorized
    @Published var user: TumbleUser? = nil
    @Published var refreshToken: Token? = nil
    @Published var sessionDetails: Token? = nil
    
    init() {
        Task.detached(priority: .userInitiated) { [weak self] in
            guard let self else { return }
            let authSchoolId = self.preferenceService.authSchoolId
            await self.autoLogin(authSchoolId: authSchoolId)
        }
    }
    
    /// Attempts to log out user, and also remove any keychain items
    /// saved that are related to authorization - tokens, passwords, etc.
    func logOut() async throws {
        try await authManager.logOutUser()
        AppLogger.shared.debug("Successfully deleted items from KeyChain")
        DispatchQueue.main.async { [weak self] in
            self?.authStatus = .unAuthorized
        }
    }
    
    /// Attempts to log in the user through their institutional credentials
    /// and saves any information it can in keychain storage, such as the
    /// refresh token, user name, password.
    func logIn(
        authSchoolId: Int,
        username: String,
        password: String
    ) async throws {
        do {
            let userRequest = NetworkRequest.KronoxUserLogin(username: username, password: password)
            let user: TumbleUser = try await authManager.loginUser(authSchoolId: authSchoolId, user: userRequest)
            try await self.authManager.setUser(user)
            let refreshToken: Token? = await authManager.getToken(.refreshToken)
            let sessionDetails: Token? = await authManager.getToken(.sessionDetails)
            DispatchQueue.main.async {
                AppLogger.shared.debug("Successfully logged in user \(user.username)")
                self.user = user
                self.refreshToken = refreshToken
                self.sessionDetails = sessionDetails
                self.authStatus = .authorized
            }
        } catch {
            DispatchQueue.main.async {
                AppLogger.shared.error("Failed to log in user -> \(error)")
                self.authStatus = .unAuthorized
            }
            throw Error.generic(reason: "Failed to log in user")
        }
    }
    
    /// Attempts to automatically log in the user by finding any available
    /// information in the keychain storage of the phone.
    func autoLogin(authSchoolId: Int) async {
        AppLogger.shared.debug("Attempting auto login for user", source: "UserController")
        let refreshToken: Token? = await authManager.getToken(.refreshToken)
        let sessionDetails: Token? = await authManager.getToken(.sessionDetails)
        do {
            let user: TumbleUser = try await authManager.autoLoginUser(authSchoolId: authSchoolId)
            try await self.authManager.setUser(user)
            
            DispatchQueue.main.async {
                self.user = user
                self.refreshToken = refreshToken
                self.sessionDetails = sessionDetails
                self.authStatus = .authorized
            }
        } catch AuthManager.AuthError.autoLoginError(let user) {
            DispatchQueue.main.async {
                self.user = user
                self.authStatus = .authorized
            }
        } catch {
            AppLogger.shared.error("Failed to log in user: \(error)")
            DispatchQueue.main.async {
                self.authStatus = .unAuthorized
            }
        }
    }
    
}
