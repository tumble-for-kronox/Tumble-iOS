//
//  UserModel.swift
//  Tumble
//
//  Created by Adis Veletanlic on 2023-02-13.
//

import Foundation
import SwiftUI

/// Observable User model, changes to this object will
/// trigger UI changes wherever there are listeners
final class UserController: ObservableObject {
    @Inject var authManager: AuthManager
    @Inject var kronoxManager: KronoxManager
    @Inject var preferenceService: PreferenceService
    
    @Published var authStatus: AuthStatus = .loading
    @Published var user: TumbleUser? = nil
    @Published var refreshToken: Token? = nil
    
    init() {
        
        Task.detached(priority: .userInitiated) { [weak self] in
            let authSchoolId = self?.preferenceService.getDefaultAuthSchool() ?? -1
            await self?.autoLogin(authSchoolId: authSchoolId)
        }
    }
    
    var autoSignup: Bool {
        get { preferenceService.getDefault(key: StoreKey.autoSignup.rawValue) as? Bool ?? false }
        set { preferenceService.setAutoSignup(autoSignup: newValue) }
    }
    
    func logOut() async throws {
        try await authManager.logOutUser()
        AppLogger.shared.debug("Successfully deleted items from KeyChain")
        DispatchQueue.main.async { [weak self] in
            self?.authStatus = .unAuthorized
        }
    }

    func logIn(
        authSchoolId: Int,
        username: String,
        password: String
    ) async throws {
        do {
            DispatchQueue.main.async {
                self.authStatus = .loading
            }
            let userRequest = Request.KronoxUserLogin(username: username, password: password)
            let user: TumbleUser = try await authManager.loginUser(authSchoolId: authSchoolId, user: userRequest)
            try await self.authManager.setUser(newValue: user)
            let token: Token? = await authManager.getToken(tokenType: .refreshToken)
            DispatchQueue.main.async {
                AppLogger.shared.debug("Successfully logged in user \(user.username)")
                self.user = user
                self.refreshToken = token
                self.authStatus = .authorized
            }
        } catch (let error) {
            DispatchQueue.main.async {
                AppLogger.shared.critical("Failed to log in user -> \(error)")
                self.authStatus = .unAuthorized
            }
            throw Error.generic(reason: "Failed to log in user")
        }
    }
    
    func autoLogin(authSchoolId: Int) async {
        AppLogger.shared.debug("Attempting auto login for user", source: "UserController")
        DispatchQueue.main.async {
            self.authStatus = .loading
        }
        do {
            let user: TumbleUser = try await authManager.autoLoginUser(authSchoolId: authSchoolId)
            try await self.authManager.setUser(newValue: user)
            let token: Token? = await authManager.getToken(tokenType: .refreshToken)
            DispatchQueue.main.async {
                self.user = user
                self.refreshToken = token
                self.authStatus = .authorized
            }
        } catch (let error) {
            AppLogger.shared.critical("Failed to log in user: \(error)")
            DispatchQueue.main.async {
                self.authStatus = .unAuthorized
            }
        }
    }
    
}
