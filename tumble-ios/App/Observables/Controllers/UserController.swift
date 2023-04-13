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

}
