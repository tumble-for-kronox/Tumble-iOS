//
//  AccountPageView-ViewModel.swift
//  tumble-ios
//
//  Created by Adis Veletanlic on 2023-01-25.
//

import Foundation

enum AccountPageViewStatus {
    case loading
    case authorized
    case error
    case unAuthorized
}

extension AccountPage {
    @MainActor final class AccountPageViewModel: ObservableObject {
        
        @Inject var networkManager: NetworkManager
        @Inject var preferenceService: PreferenceService
        @Inject var authManager: AuthManager
        
        @Published var school: School?
        @Published var status: AccountPageViewStatus = .unAuthorized
        @Published var autoSignup: Bool = false
        
        init() {
            self.school = preferenceService.getDefaultSchool()
            self.autoSignup = preferenceService.getDefault(key: StoreKey.autoSignup.rawValue) as? Bool ?? false
            self.loadUser()
        }
        
        fileprivate func loadUser() -> Void {
            self.status = .loading
            if authManager.user != nil {
                self.status = .authorized
            } else {
                self.status = .unAuthorized
            }
        }
        
        fileprivate func toggleAutoSignup() {
            self.autoSignup.toggle()
            self.preferenceService.setAutoSignup(autoSignup: self.autoSignup)
        }
        
        func login(username: String, password: String) -> Void {
            self.school = preferenceService.getDefaultSchool()
            AppLogger.shared.info("Attempting to login user ...")
            self.status = .loading
            let body = Request.KronoxUserLogin(username: username, password: password)
            AppLogger.shared.info("\(body)")
            
            authManager.loginUser(user: body, completionHandler: { [weak self] (result: Result<Response.KronoxUser, Error>) in
                guard let self = self else { return }
                DispatchQueue.main.async {
                    switch result {
                    case .success(_):
                        AppLogger.shared.info("Successfully signed in user")
                        self.status = .authorized
                    case .failure(let error):
                        AppLogger.shared.info("Failed to sign in user -> \(error.localizedDescription)")
                        self.status = .unAuthorized
                    }
                }
            })
        }
        
        func logOut() -> Void {
            self.status = .loading
            AppLogger.shared.info("Attempting to log out user ...")
            authManager.logOutUser(completionHandler: { (result: Result<Int, Error>) in
                
            })
        }
        
    }
}
