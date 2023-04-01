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
    func setSchool(id: Int, closure: @escaping () -> Void) -> Void
    
    func setUserOnboarded() -> Void
    
    func setProfileImage(image: UIImage?, forKey key: String) -> Void
    
    func setOffset(offset: Int) -> Void
    
    func setBookmarks(bookmark: String) -> Void
    
    func setBookmarks(bookmarks: [Bookmark]) -> Void
    
    func setAppearance(appearance: String) -> Void
        
    func setLang(lang: String) -> Void
    
    func setAutoSignup(autoSignup: Bool) -> Void
    
    func setViewType(viewType: Int) -> Void
        
    func toggleBookmark(bookmark: String, value: Bool) -> Void
    
    // ----------- GET -----------
    func getDefault(key: String) -> Any?
    
    func getDefaultViewType() -> BookmarksViewType
    
    func getDefaultSchoolName(schools: [School]) -> School?
    
    func isKeyPresentInUserDefaults(key: String) -> Bool
}
