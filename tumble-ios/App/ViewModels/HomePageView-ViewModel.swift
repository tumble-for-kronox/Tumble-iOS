//
//  HomePageView-ViewModel.swift
//  tumble-ios
//
//  Created by Adis Veletanlic on 11/20/22.
//

import Foundation
import SwiftUI

extension HomeView {
    @MainActor final class HomeViewModel: ObservableObject {
        
        @Inject var preferenceService: PreferenceService
        
        let ladokUrl: String = "https://www.student.ladok.se/student/app/studentwebb/"
        
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
        
        func makeCanvasUrl() -> URL? {
            return URL(string: preferenceService.getCanvasUrl() ?? "")
        }
        
        func makeUniversityUrl() -> URL? {
            return URL(string: preferenceService.getUniversityUrl() ?? "")
        }

    }
}
