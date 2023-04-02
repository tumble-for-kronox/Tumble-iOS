//
//  UserControllerExtension.swift
//  tumble-ios
//
//  Created by Adis Veletanlic on 2023-04-01.
//

import Foundation

extension UserController {
    
    func logOut(completion: ((Bool) -> Void)? = nil) {
        self.authManager.logOutUser(completionHandler: { [weak self] result in
            guard let self = self else { return }
            DispatchQueue.main.async {
                switch result {
                case .success(let amount):
                    AppLogger.shared.debug("Successfully deleted \(amount) items from KeyChain")
                    self.user = nil
                    self.authStatus = .unAuthorized
                    completion?(true)
                case .failure(_):
                    AppLogger.shared.critical("Could not clear user from KeyChain")
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
                    AppLogger.shared.debug("Successfully logged in user \(user.username)")
                    self.user = TumbleUser(username: user.username, password: password, name: user.name)
                    self.authStatus = .authorized
                    completion?(true)
                case .failure(let failure):
                    AppLogger.shared.critical("Failed to log in user -> \(failure.localizedDescription)")
                    self.authStatus = .unAuthorized
                    completion?(false)
                }
            }
        })
    }
    
    
    func autoLogin(completion: (() -> Void)? = nil) {
        AppLogger.shared.debug("Attempting auto login for user", source: "UserController")
        self.authManager.autoLoginUser(completionHandler: { [unowned self] result in
            switch result {
            case .success(let user):
                AppLogger.shared.debug("Successfully logged in user \(user.username)")
                DispatchQueue.main.async {
                    self.user = TumbleUser(username: user.username, password: user.password, name: user.name)
                    self.authStatus = .authorized
                }
                completion?()
            case .failure(let failure):
                AppLogger.shared.critical("Failed to log in user -> \(failure.localizedDescription)")
                DispatchQueue.main.async {
                    self.authStatus = .unAuthorized
                }
                completion?()
            }
        })
    }

}
