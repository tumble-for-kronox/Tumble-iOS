//
//  UserModel.swift
//  tumble-ios
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
    
    func authenticateAndExecute(
        tries: Int = 0,
        schoolId: Int,
        refreshToken: Token?,
        execute: @escaping (Result<(Int, String), Error>) -> Void
    ) {
        
        guard let refreshToken = refreshToken,
              !refreshToken.isExpired() else {
            if tries < NetworkConstants.MAX_CONSECUTIVE_ATTEMPTS && authStatus == .authorized {
                AppLogger.shared.debug("Attempting auto login ...")
                autoLogin { [unowned self] in
                    self.authenticateAndExecute(
                        tries: tries + 1,
                        schoolId: schoolId,
                        refreshToken: refreshToken,
                        execute: execute
                    )
                }
            } else {
                execute(.failure(.internal(reason: "Could not authenticate user")))
            }
            return
        }
        execute(.success((schoolId, refreshToken.value)))
    }

}
