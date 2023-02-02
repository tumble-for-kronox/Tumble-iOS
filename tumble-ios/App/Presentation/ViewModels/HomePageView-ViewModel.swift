//
//  HomePageView-ViewModel.swift
//  tumble-ios
//
//  Created by Adis Veletanlic on 11/20/22.
//

import Foundation
import SwiftUI

extension HomePageView {
    @MainActor final class HomePageViewModel: ObservableObject {
        
        @Published var kronoxUrl: String?
        @Published var canvasUrl: String?
        @Published var domain: String?
        
        let preferenceService: PreferenceServiceImpl
        
        init(preferenceService: PreferenceServiceImpl, kronoxUrl: String?, canvasUrl: String?, domain: String?) {
            self.preferenceService = preferenceService
            self.kronoxUrl = kronoxUrl
            self.canvasUrl = canvasUrl
            self.domain = domain
        }
        
        func updateUniversityLocalsForView() -> Void {
            self.kronoxUrl = preferenceService.getUniversityKronoxUrl()
            self.canvasUrl = preferenceService.getCanvasUrl()
            self.domain = preferenceService.getUniversityDomain()
        }
        
        func getTimeOfDay() -> String {
            let date = Date()
            let calendar = Calendar.current
            let hour = calendar.component(.hour, from: date)

            switch hour {
            case 0...11:
                return "morning"
            case 12...16:
                return "afternoon"
            default:
                return "evening"
            }
        }

    }
}
