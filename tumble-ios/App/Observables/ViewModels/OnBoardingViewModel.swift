//
//  OnBoardingViewModel.swift
//  tumble-ios
//
//  Created by Adis Veletanlic on 2023-01-28.
//

import Foundation

@MainActor final class OnBoardingViewModel: ObservableObject {
    
    @Inject private var preferenceService: PreferenceService
    @Inject private var schoolManager: SchoolManager
    
    var schools: [School] {
        return schoolManager.getSchools()
    }
    
    func onSelectSchool(school: School, updateUserOnBoarded: @escaping UpdateUserOnBoarded) -> Void {
        preferenceService.setSchool(id: school.id) {
            self.preferenceService.setUserOnboarded()
            updateUserOnBoarded()
        }
    }
    
}
