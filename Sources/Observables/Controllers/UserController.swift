//
//  UserModel.swift
//  Tumble
//
//  Created by Adis Veletanlic on 2023-02-13.
//

import Foundation
import SwiftUI

// Observable User model, changes to this object will
// trigger UI changes wherever there are listeners
class UserController: ObservableObject {
    @Inject var authManager: AuthManager
    @Inject var kronoxManager: KronoxManager
    @Inject var preferenceService: PreferenceService
    
    @Published var authStatus: AuthStatus = .loading
    
    init() {
        let authSchoolId = preferenceService.getDefaultAuthSchool() ?? -1
        let inAppReview = preferenceService.isInAppReview()
        if inAppReview {
            self.authStatus = .authorized
            return
        }
        autoLogin(authSchoolId: authSchoolId, completion: {
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

    var refreshToken: Token? { authManager.refreshToken }
    
    var autoSignup: Bool {
        get { preferenceService.getDefault(key: StoreKey.autoSignup.rawValue) as? Bool ?? false }
        set { preferenceService.setAutoSignup(autoSignup: newValue) }
    }
    
    func authenticateAndExecute(
        tries: Int = 0,
        authSchoolId: Int,
        refreshToken: Token?,
        execute: @escaping (NetworkResult<(Int, String), Error>) -> Void
    ) {
        
        // Check if in review by apple
        if preferenceService.inAppReview {
            execute(.demo)
            return
        }
        
        guard let refreshToken = refreshToken,
              !refreshToken.isExpired()
        else {
            if tries < NetworkConstants.MAX_CONSECUTIVE_ATTEMPTS && authStatus == .authorized {
                AppLogger.shared.debug("Attempting auto login ...")
                autoLogin(authSchoolId: authSchoolId) { [unowned self] in
                    self.authenticateAndExecute(
                        tries: tries + 1,
                        authSchoolId: authSchoolId,
                        refreshToken: refreshToken,
                        execute: execute
                    )
                }
            } else {
                execute(.failure(.internal(reason: "Could not authenticate user")))
            }
            return
        }
        execute(.success((authSchoolId, refreshToken.value)))
    }
}
