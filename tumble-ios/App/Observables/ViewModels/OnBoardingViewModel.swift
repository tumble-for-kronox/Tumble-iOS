//
//  OnBoardingViewModel.swift
//  tumble-ios
//
//  Created by Adis Veletanlic on 2023-01-28.
//

import Foundation

final class OnBoardingViewModel: ObservableObject {
    
    @Inject private var preferenceService: PreferenceService
    @Inject private var schoolManager: SchoolManager
    
    @Published var showSchoolSelection: Bool = false
    
    lazy var schools: [School] = schoolManager.getSchools()
    
    @MainActor
    func onSelectSchool(school: School) -> Void {
        showSchoolSelection = false
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            guard let self else { return }
            self.preferenceService.setSchool(id: school.id)
            self.preferenceService.setUserOnboarded()
        }
    }
    
}
