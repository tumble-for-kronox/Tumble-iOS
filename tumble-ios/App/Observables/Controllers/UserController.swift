//
//  UserModel.swift
//  tumble-ios
//
//  Created by Adis Veletanlic on 2023-02-13.
//

import Foundation
import SwiftUI

struct TumbleUser: Decodable, Encodable {
    var username: String
    var password: String
    var name: String
}

enum AuthStatus {
    case authorized
    case unAuthorized
}

// Observable User model, changes to this object will
// trigger UI changes wherever there are listeners
class UserController: ObservableObject {
        
    @Inject private var authManager: AuthManager
    @Inject private var networkManager: NetworkManager
    @Inject private var preferenceService: PreferenceService
    
    @Published var authStatus: AuthStatus = .unAuthorized
    
    init() {
        autoLogin(completion: {
            DispatchQueue.main.async {
                if self.user != nil {
                    self.authStatus = .authorized
                } else {
                    self.authStatus = .unAuthorized
                }
            }
        })
    }
    
    var user: TumbleUser? {
        get { return authManager.user }
        set { authManager.user = newValue }
    }

    var refreshToken: Token? {
        get { authManager.refreshToken }
    }
    
    var autoSignup: Bool {
        get { preferenceService.getDefault(key: StoreKey.autoSignup.rawValue) as? Bool ?? false }
        set { preferenceService.setAutoSignup(autoSignup: newValue) }
    }

}



extension UserController {
    
    func logOut(completion: ((Bool) -> Void)? = nil) {
        self.authManager.logOutUser(completionHandler: { [weak self] result in
            guard let self = self else { return }
            DispatchQueue.main.async {
                switch result {
                case .success(let amount):
                    AppLogger.shared.info("Successfully deleted \(amount) items from KeyChain")
                    self.user = nil
                    self.authStatus = .unAuthorized
                    self.preferenceService.setProfileImage(image: nil)
                    completion?(true)
                case .failure(_):
                    AppLogger.shared.info("Could not clear user from KeyChain")
                    completion?(false)
                }
            }
        })
    }

    
    func logIn(username: String, password: String, completion: ((Bool) -> Void)? = nil) {
        let user = Request.KronoxUserLogin(username: username, password: password)
        self.authManager.loginUser(user: user, completionHandler: { [weak self] result in
            guard let self = self else { return }
            DispatchQueue.main.async {
                switch result {
                case .success(let user):
                    AppLogger.shared.info("Successfully logged in user \(user.username)")
                    self.user = TumbleUser(username: user.username, password: password, name: user.name)
                    self.authStatus = .authorized
                    completion?(true)
                case .failure(let failure):
                    AppLogger.shared.info("Failed to log in user -> \(failure.localizedDescription)")
                    self.authStatus = .unAuthorized
                    completion?(false)
                }
            }
        })
    }
    
    
    func autoLogin(completion: (() -> Void)? = nil) {
        AppLogger.shared.info("Attempting auto login for user", source: "UserController")
        self.authManager.autoLoginUser(completionHandler: { [unowned self] result in
            switch result {
            case .success(let user):
                AppLogger.shared.info("Successfully logged in user \(user.username)")
                self.user = TumbleUser(username: user.username, password: user.password, name: user.name)
                self.authStatus = .authorized
                completion?()
            case .failure(let failure):
                AppLogger.shared.info("Failed to log in user -> \(failure.localizedDescription)")
                self.authStatus = .unAuthorized
                completion?()
            }
        })
    }

}

