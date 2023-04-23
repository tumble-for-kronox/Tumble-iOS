//
//  OnBoardingViewModel.swift
//  Tumble
//
//  Created by Adis Veletanlic on 2023-01-28.
//

import Foundation

final class OnBoardingViewModel: ObservableObject {
    @Inject private var preferenceService: PreferenceService
    
    func finishOnboarding() {
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            guard let self else { return }
            self.preferenceService.setUserOnboarded()
        }
    }
}
