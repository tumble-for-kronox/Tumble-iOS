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
    func setSchool(id: Int) -> Void
    
    func setUserOnboarded() -> Void
    
    func setOffset(offset: Int) -> Void
    
    func addBookmark(id: String) -> Void
    
    func removeBookmark(id: String) -> Void
    
    func setAppearance(appearance: String) -> Void
        
    func setLang(lang: String) -> Void
    
    func setAutoSignup(autoSignup: Bool) -> Void
    
    func setViewType(viewType: Int) -> Void
        
    func toggleBookmark(bookmark: String, value: Bool) -> Void
    
    // ----------- GET -----------
    func getDefault(key: String) -> Any?
    
    func getDefaultViewType() -> BookmarksViewType
    
    func getDefaultSchoolName(schools: [School]) -> String
    
    func isKeyPresentInUserDefaults(key: String) -> Bool
}
