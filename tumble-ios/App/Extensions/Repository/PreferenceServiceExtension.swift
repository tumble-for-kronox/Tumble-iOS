//
//  PreferenceServiceExtension.swift
//  tumble-ios
//
//  Created by Adis Veletanlic on 2023-02-02.
//

import Foundation
import SwiftUI


// Functions not inherently related to iOS local storage
extension PreferenceService {
    
    func getUniversityImage(schools: [School]) -> Image? {
        guard let school: School = self.getDefaultSchoolName(schools: schools) else { return nil }
        let schoolImage: Image = schools.first(where: {$0.name == school.name})!.logo
        return schoolImage
    }
    
    func getUniversityName(schools: [School]) -> String? {
        guard let school: School = self.getDefaultSchoolName(schools: schools) else { return nil }
                let schoolName: String = schools.first(where: {$0.name == school.name})!.name
        return schoolName
    }
    
    func getUniversityUrl(schools: [School]) -> String? {
        guard let school: School = self.getDefaultSchoolName(schools: schools) else { return nil }
        let schoolUrl: String = schools.first(where: {$0.name == school.name})!.schoolUrl
        return schoolUrl
    }
    
    func getCanvasUrl(schools: [School]) -> String? {
        guard let school: School = self.getDefaultSchoolName(schools: schools) else { return nil }
        let domain: String = schools.first(where: {$0.name == school.name})!.domain
        let canvasUrl: String = "https://\(domain).instructure.com"
        return canvasUrl
    }
    
    func getUniversityKronoxUrl(schools: [School]) -> String? {
        guard let school: School = self.getDefaultSchoolName(schools: schools) else { return nil }
        let kronoxUrl: String = schools.first(where: {$0.name == school.name})!.kronoxUrl
        return kronoxUrl
    }
    
    func getUniversityDomain(schools: [School]) -> String? {
        guard let school: School = self.getDefaultSchoolName(schools: schools) else { return nil }
        let domain: String = schools.first(where: {$0.name == school.name})!.domain
        return domain
    }
    
    func getUniversityColor(schools: [School]) -> Color {
        let school: School? = self.getDefaultSchoolName(schools: schools)
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
