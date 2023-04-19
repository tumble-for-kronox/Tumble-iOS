//
//  DatabaseRepository.swift
//  tumble-ios
//
//  Created by Adis Veletanlic on 2023-01-27.
//

import Foundation
import UIKit

protocol PreferenceServiceProtocol {
    // ----------- SET -----------
    func setAuthSchool(id: Int) -> Void
    
    func setUserOnboarded() -> Void
    
    func setOffset(offset: Int) -> Void
    
    func setAppearance(appearance: String) -> Void
        
    func setLang(lang: String) -> Void
    
    func setAutoSignup(autoSignup: Bool) -> Void
    
    func setViewType(viewType: Int) -> Void
        
    // ----------- GET -----------
    func getDefault(key: String) -> Any?
    
    func getDefaultViewType() -> BookmarksViewType
    
    func getDefaultAuthSchoolName(schools: [School]) -> String
    
    func isKeyPresentInUserDefaults(key: String) -> Bool
}
