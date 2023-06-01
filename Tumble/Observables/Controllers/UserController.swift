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
    @Published var user: TumbleUser? = nil
    @Published var refreshToken: Token? = nil
    
    init() {
        let authSchoolId = preferenceService.getDefaultAuthSchool() ?? -1
        Task {
            await autoLogin(authSchoolId: authSchoolId)
        }
    }
    
    var autoSignup: Bool {
        get { preferenceService.getDefault(key: StoreKey.autoSignup.rawValue) as? Bool ?? false }
        set { preferenceService.setAutoSignup(autoSignup: newValue) }
    }
    
}
