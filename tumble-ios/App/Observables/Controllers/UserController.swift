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
    
    static let shared: UserController = UserController()
    
    @Inject private var authManager: AuthManager
    @Inject private var networkManager: NetworkManager
    @Inject private var preferenceService: PreferenceService
    
    @Published var authStatus: AuthStatus = .unAuthorized
    @Published var completeUserEvent: Response.KronoxCompleteUserEvent? = nil
    @Published var userBookings: Response.KronoxUserBooking? = nil

    
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
    
    var profilePicture: UIImage? {
        get { loadProfilePicture() }
        set { saveProfilePicture(image: newValue) }
    }

    var refreshToken: Token? {
        get { authManager.refreshToken }
    }
    
    var sessionToken: Token? {
        get { authManager.sessionToken }
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
        self.authManager.autoLoginUser(completionHandler: { [weak self] result in
            guard let self = self else { return }
            DispatchQueue.main.async {
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
            }
        })
    }
    
    
    
    func registerForEvent(tries: Int = 0, with id: String, completion: @escaping (Result<Response.HTTPResponse, Error>) -> Void) {
        guard let school = preferenceService.getDefaultSchool(),
                let sessionToken = self.sessionToken,
              !sessionToken.isExpired() else {
            if tries < NetworkConstants.MAX_CONSECUTIVE_ATTEMPTS {
                autoLogin(completion: {
                    self.registerForEvent(tries: tries + 1, with: id, completion: completion)
                })
            }
            completion(.failure(.generic(reason: "Could not reach server in time")))
            return
        }
        AppLogger.shared.info("Registering for event -> \(id)")
        let request = Endpoint.registerEvent(eventId: id, schoolId: String(school.id), sessionToken: sessionToken.value)
        self.networkManager.put(request, then: completion)
    }
    
    func unregisterForEvent(tries: Int = 0, with id: String, completion: @escaping (Result<Response.HTTPResponse, Error>) -> Void) -> Void {
        guard let school = preferenceService.getDefaultSchool(),
                let sessionToken = self.sessionToken,
              !sessionToken.isExpired() else {
            if tries < NetworkConstants.MAX_CONSECUTIVE_ATTEMPTS {
                autoLogin(completion: {
                    self.unregisterForEvent(tries: tries + 1, with: id, completion: completion)
                })
            }
            completion(.failure(.generic(reason: "Could not reach server in time")))
            return
        }
        AppLogger.shared.info("Unregistering for event -> \(id)")
        let request = Endpoint.unregisterEvent(eventId: id, schoolId: String(school.id), sessionToken: sessionToken.value)
        self.networkManager.put(request, then: completion)
    }
    
    
    func getUserEvents(tries: Int = 0, completion: @escaping (Bool) -> Void) {
        guard let school = preferenceService.getDefaultSchool(),
              let sessionToken = self.sessionToken,
              !sessionToken.isExpired() else {
            if tries < NetworkConstants.MAX_CONSECUTIVE_ATTEMPTS {
                autoLogin(completion: {
                    self.getUserEvents(tries: tries + 1, completion: completion)
                })
            }
            completion(false)
            return
        }
        
        let request = Endpoint.userEvents(sessionToken: sessionToken.value, schoolId: String(school.id))
        self.networkManager.get(request) { [weak self] (result: Result<Response.KronoxCompleteUserEvent, Error>) in
            guard let self = self else { return }
            DispatchQueue.main.async {
                switch result {
                case .success(let completeUserEvent):
                    AppLogger.shared.info("Successfully loaded user events")
                    self.completeUserEvent = completeUserEvent
                    completion(true)
                case .failure(let failure):
                    AppLogger.shared.info("Failed to retrieve user events -> \(failure)")
                    completion(false)
                }
            }
        }
    }

    
    func getUserBookings(tries: Int = 0, completion: @escaping (Bool) -> Void) -> Void {
        guard let school = preferenceService.getDefaultSchool(),
              let sessionToken = self.sessionToken,
              !sessionToken.isExpired() else {
            if tries < NetworkConstants.MAX_CONSECUTIVE_ATTEMPTS {
                autoLogin(completion: {
                    self.getUserEvents(tries: tries + 1, completion: completion)
                })
            }
            completion(false)
            return
        }
        let request = Endpoint.userBookings(schoolId: String(school.id), sessionToken: sessionToken.value)
        self.networkManager.get(request) { [weak self] (result: Result<Response.KronoxUserBooking, Error>) in
            guard let self = self else { return }
            DispatchQueue.main.async {
                switch result {
                case .success(let userBookings):
                    AppLogger.shared.info("Successfully loaded user bookings")
                    self.userBookings = userBookings
                    completion(true)
                case .failure(let failure):
                    AppLogger.shared.info("Failed to retrieve user bookings -> \(failure)")
                    completion(false)
                }
            }
        }
    }
        
    fileprivate func loadProfilePicture() -> UIImage? {
        if let fileName = UserDefaults.standard.value(forKey: StoreKey.profileImage.rawValue) as? String,
           let fileURL = try? FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false).appendingPathComponent(fileName),
           let data = try? Data(contentsOf: fileURL),
           let image = UIImage(data: data) {
            return image
        }
        return nil
    }
    
    fileprivate func saveProfilePicture(image: UIImage?) -> Void {
        let fileName = "profile_picture.png"
        let fileURL = try! FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false).appendingPathComponent(fileName)

        if let data = image?.pngData() {
            try? data.write(to: fileURL)
            UserDefaults.standard.set(fileName, forKey: StoreKey.profileImage.rawValue)
        }
    }
}
