//
//  OnBoardingViewModel.swift
//  tumble-ios
//
//  Created by Adis Veletanlic on 2023-01-28.
//

import Foundation

extension OnBoardingView {
    @MainActor final class OnBoardingViewModel: ObservableObject {
        
        @Inject var preferenceService: PreferenceService
        
        var showModal: Bool = true
        
        func onSelectSchool(school: School, updateUserOnBoarded: @escaping UpdateUserOnBoarded) -> Void {
            preferenceService.setSchool(id: school.id) {
                self.preferenceService.setUserOnboarded()
                updateUserOnBoarded()
            }
        }
        
    }
}
