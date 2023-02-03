//
//  PreferenceServiceExtension.swift
//  tumble-ios
//
//  Created by Adis Veletanlic on 2023-02-02.
//

import Foundation
import SwiftUI


// Functions not inherently related to iOS local storage
extension PreferenceServiceProtocol {
    
    func getUniversityImage() -> Image? {
        guard let school: School = self.getDefaultSchool() else { return nil }
        let schoolImage: Image = schools.first(where: {$0.name == school.name})!.logo
        return schoolImage
    }
    
    func getUniversityName() -> String? {
        guard let school: School = self.getDefaultSchool() else { return nil }
                let schoolName: String = schools.first(where: {$0.name == school.name})!.name
        return schoolName
    }
    
    func getUniversityUrl() -> String? {
        guard let school: School = self.getDefaultSchool() else { return nil }
        let schoolUrl: String = schools.first(where: {$0.name == school.name})!.schoolUrl
        return schoolUrl
    }
    
    func getCanvasUrl() -> String? {
        guard let school: School = self.getDefaultSchool() else { return nil }
        let domain: String = schools.first(where: {$0.name == school.name})!.domain
        let canvasUrl: String = "https://\(domain).instructure.com"
        return canvasUrl
    }
    
    func getUniversityKronoxUrl() -> String? {
        guard let school: School = self.getDefaultSchool() else { return nil }
        let kronoxUrl: String = schools.first(where: {$0.name == school.name})!.kronoxUrl
        return kronoxUrl
    }
    
    func getUniversityDomain() -> String? {
        guard let school: School = self.getDefaultSchool() else { return nil }
        let domain: String = schools.first(where: {$0.name == school.name})!.domain
        return domain
    }
    
    func getUniversityColor() -> Color {
        let school: School? = self.getDefaultSchool()
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
}
