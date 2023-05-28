//
//  UserControllerExtension.swift
//  Tumble
//
//  Created by Adis Veletanlic on 2023-04-01.
//

import Foundation

extension UserController {
    func logOutDemo() async throws {
        preferenceService.setInAppReview(value: false)
        try await authManager.setUser(newValue: nil)
        authStatus = .unAuthorized
    }

    func logOut() async throws {
        if preferenceService.inAppReview {
            try await logOutDemo()
        } else {
            try await authManager.logOutUser()
        }
        try await authManager.setUser(newValue: nil)
        AppLogger.shared.debug("Successfully deleted items from KeyChain")
        DispatchQueue.main.async { [weak self] in
            self?.authStatus = .unAuthorized
        }
    }
    
    func loginDemo(
        username: String,
        password: String
    ) async throws {
        try await self.authManager.setUser(newValue: TumbleUser(username: username, password: password, name: "App Review Team"))
        DispatchQueue.main.async {
            self.authStatus = .authorized
        }
    }

    func logIn(
        authSchoolId: Int,
        username: String,
        password: String
    ) async throws {
        do {
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
        do {
            let user: TumbleUser = try await authManager.autoLoginUser(authSchoolId: authSchoolId)
            print(user.name)
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
