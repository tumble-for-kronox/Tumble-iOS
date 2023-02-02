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
}
