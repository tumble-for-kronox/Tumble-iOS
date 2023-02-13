//
//  UserModel.swift
//  tumble-ios
//
//  Created by Adis Veletanlic on 2023-02-13.
//

import Foundation

struct TumbleUser: Decodable, Encodable {
    var username: String
    var name: String
}

enum AuthStatus {
    case authorized
    case unAuthorized
}

class UserModel: ObservableObject {
    
    @Inject var authManager: AuthManager
    
    @Published var authStatus: AuthStatus = .unAuthorized
    var user: TumbleUser? {
        get { return authManager.user }
        set { authManager.user = newValue }
    }
    
    init() {
        if self.user != nil {
            self.authStatus = .authorized
        } else {
            self.authStatus = .unAuthorized
        }
    }
    
    func logOut(completion: @escaping (Bool) -> Void) {
        self.authManager.logOutUser(completionHandler: { [weak self] result in
            guard let self = self else { return }
            DispatchQueue.main.async {
                switch result {
                case .success(let amount):
                    AppLogger.shared.info("Successfully deleted \(amount) items from KeyChain")
                    self.user = nil
                    self.authStatus = .unAuthorized
                    completion(true)
                case .failure(_):
                    AppLogger.shared.info("Could not clear user from KeyChain")
                    completion(false)
                }
            }
        })
    }
    
    func logIn(username: String, password: String, completion: @escaping (Bool) -> Void) {
        let user = Request.KronoxUserLogin(username: username, password: password)
        self.authManager.loginUser(user: user, completionHandler: { [weak self] result in
            guard let self = self else { return }
            DispatchQueue.main.async {
                switch result {
                case .success(let user):
                    AppLogger.shared.info("Successfully logged in user \(user.username)")
                    self.user = TumbleUser(username: user.username, name: user.name)
                    self.authStatus = .authorized
                    completion(true)
                case .failure(let failure):
                    AppLogger.shared.info("Failed to log in user -> \(failure.localizedDescription)")
                    completion(false)
                }
            }
        })
    }
    
    func autoLogin() {
        self.authManager.autoLoginUser(completionHandler: { [weak self] result in
            guard let self = self else { return }
            DispatchQueue.main.async {
                switch result {
                case .success(let user):
                    AppLogger.shared.info("Successfully logged in user \(user.username)")
                    self.user = TumbleUser(username: user.username, name: user.name)
                    self.authStatus = .authorized
                case .failure(let failure):
                    AppLogger.shared.info("Failed to log in user -> \(failure.localizedDescription)")
                }
            }
        })
    }
    
}
