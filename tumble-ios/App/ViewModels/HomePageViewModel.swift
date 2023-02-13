//
//  HomePageView-ViewModel.swift
//  tumble-ios
//
//  Created by Adis Veletanlic on 11/20/22.
//

import Foundation
import SwiftUI

extension HomePage {
    @MainActor final class HomePageViewModel: ObservableObject {
        
        @Inject var preferenceService: PreferenceService
        @Inject var authManager: AuthManager
        
        let ladokUrl: String = "https://www.student.ladok.se/student/app/studentwebb/"
        
        var user: TumbleUser? {
            get { return authManager.user }
        }
        
        func getTimeOfDay() -> String {
            let date = Date()
            let calendar = Calendar.current
            let hour = calendar.component(.hour, from: date)

            switch hour {
            case 0...11:
                return "morning"
            case 12...18:
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
