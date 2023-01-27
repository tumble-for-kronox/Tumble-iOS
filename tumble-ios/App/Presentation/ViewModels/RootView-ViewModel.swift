//
//  TabSwitcherView-ViewModel.swift
//  tumble-ios
//
//  Created by Adis Veletanlic on 11/20/22.
//

import Foundation

extension RootView {
    @MainActor final class RootViewModel: ObservableObject {

        @Published var missingSchool: Bool
        @Published var userOnBoarded: Bool
        let databaseService: PreferenceServiceImpl
        
        init (missingSchool: Bool, userOnboarded: Bool, databaseService: PreferenceServiceImpl) {
            self.missingSchool = missingSchool
            self.userOnBoarded = userOnboarded
            self.databaseService = databaseService
        }
        
        func onUserOnboarded() -> Void {
            databaseService.setUserOnboarded()
        }
        
        func onSelectSchool(school: School) -> Void {
            print(missingSchool)
            databaseService.setSchool(id: school.id)
            DispatchQueue.main.async {
                self.missingSchool = false
            }
        }
    }
}
