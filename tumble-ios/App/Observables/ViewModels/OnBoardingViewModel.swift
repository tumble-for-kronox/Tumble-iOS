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
    
    @Published var showSchoolSelection: Bool = false
    
    lazy var schools: [School] = schoolManager.getSchools()
    
    func onSelectSchool(school: School, updateUserOnBoarded: @escaping UpdateUserOnBoarded) -> Void {
        showSchoolSelection = false
        preferenceService.setSchool(id: school.id) {
            self.preferenceService.setUserOnboarded()
            updateUserOnBoarded()
        }
    }
    
}
