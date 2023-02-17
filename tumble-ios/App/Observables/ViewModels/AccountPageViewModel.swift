//
//  AccountPageView-ViewModel.swift
//  tumble-ios
//
//  Created by Adis Veletanlic on 2023-01-25.
//

import Foundation

enum AccountPageViewStatus {
    case loading
    case error
    case initial
}

@MainActor final class AccountPageViewModel: ObservableObject {
    
    @Inject var networkManager: NetworkManager
    @Inject var preferenceService: PreferenceService
    
    @Published var school: School?
    @Published var status: AccountPageViewStatus = .initial
    @Published var autoSignup: Bool = false
    
    init() {
        self.autoSignup = false
        self.school = preferenceService.getDefaultSchool()
        self.autoSignup = preferenceService.getDefault(key: StoreKey.autoSignup.rawValue) as? Bool ?? false
    }
    
    func updateViewLocals() -> Void {
        self.school = preferenceService.getDefaultSchool()
        self.autoSignup = preferenceService.getDefault(key: StoreKey.autoSignup.rawValue) as? Bool ?? false
    }
    
    func toggleAutoSignup(value: Bool) {
        self.autoSignup = value
        self.preferenceService.setAutoSignup(autoSignup: value)
    }
}
