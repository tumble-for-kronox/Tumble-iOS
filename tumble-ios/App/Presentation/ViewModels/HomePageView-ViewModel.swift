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
        
        func getUniversityColor() -> Color {
            let school: School? = self.preferenceService.getDefaultSchool()
            let uniColor: Color
            
            switch school?.color {
                case "blue":
                    uniColor = Color.blue
                case "orange":
                    uniColor = Color.orange
                case "green":
                    uniColor = Color.green
                case "yellow":
                    uniColor = Color.yellow
                case "brown":
                    uniColor = Color.brown
                case "red":
                    uniColor = Color.red
                default:
                    uniColor = Color.black
                }

                return uniColor
        }
        
        func getUniversityUrl() -> String {
            let school: School? = self.preferenceService.getDefaultSchool()
            
            if school == nil {
                return ""
            }
            
            let schoolUrl: String = schools.first(where: {$0.name == school!.name})!.schoolUrl
            return schoolUrl
        }
        
        func getUniversityKronoxUrl() -> String {
            let school: School? = self.preferenceService.getDefaultSchool()
            
            if school == nil {
                return ""
            }
            
            let kronoxUrl: String = schools.first(where: {$0.name == school!.name})!.kronoxUrl
            return kronoxUrl
        }
        
        func getUniversityName() -> String {
            let school: School? = self.preferenceService.getDefaultSchool()
            
            if school == nil {
                return ""
            }
            
            let schoolName: String = schools.first(where: {$0.name == school!.name})!.name
            return schoolName
        }
        
        func getCanvasUrl() -> String {
            let school: School? = self.preferenceService.getDefaultSchool()
            
            if school == nil {
                return ""
            }
            
            let domain: String = schools.first(where: {$0.name == school!.name})!.domain
            let canvasUrl: String = "https://\(domain).instructure.com"
            return canvasUrl
        }
    }
}
