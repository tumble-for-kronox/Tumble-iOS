//
//  TabSwitcherView-ViewModel.swift
//  tumble-ios
//
//  Created by Adis Veletanlic on 11/20/22.
//

import Foundation

extension RootView {
    @MainActor class RootViewModel: ObservableObject {
        @Published var missingSchool: Bool = {
            return !UserDefaults.standard.isKeyPresentInUserDefaults(key: UserDefaults.StoreKey.school.rawValue)
        } ()
        @Published var userOnboarded: Bool = {
            return !UserDefaults.standard.isKeyPresentInUserDefaults(key: UserDefaults.StoreKey.userOnboarded.rawValue)
        }()
        

        func onUserOnboarded() -> Void {
            UserDefaults.standard.setUserOnboarded()
        }
        
        func onSelectSchool(school: School) -> Void {
            UserDefaults.standard.setSchool(id: school.id)
            print("Set school to \(school.name)")
            self.missingSchool = false
        }
    }
}
