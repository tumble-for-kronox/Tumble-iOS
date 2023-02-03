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
        
        let preferenceService: PreferenceServiceImpl
        
        init(preferenceService: PreferenceServiceImpl) {
            self.preferenceService = preferenceService
            
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
