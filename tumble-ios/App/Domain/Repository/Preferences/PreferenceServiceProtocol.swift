//
//  DatabaseRepository.swift
//  tumble-ios
//
//  Created by Adis Veletanlic on 2023-01-27.
//

import Foundation

protocol PreferenceServiceProtocol {
    // ----------- SET -----------
    func setSchool(id: Int, closure: @escaping () -> Void) -> Void
    
    func setUserOnboarded() -> Void
    
    func setOffset(offset: Int) -> Void
    
    func setBookmarks(bookmark: String) -> Void
    
    func setBookmarks(bookmarks: [Bookmark]) -> Void
    
    func setTheme(isDarkMode: Bool) -> Void
    
    func setOverrideSystemFalse() -> Void
    
    func setLang(lang: String) -> Void
    
    func setAutoSign(autoSignup: Bool) -> Void
    
    func setViewType(viewType: Int) -> Void
    
    func setOverrideSystem(value: Bool) -> Void
    
    func toggleBookmark(bookmark: String, value: Bool) -> Void
    
    // ----------- GET -----------
    func getDefault(key: String) -> Any?
    
    func getDefaultViewType() -> BookmarksViewType
    
    func getDefaultSchool() -> School?
    
    func isKeyPresentInUserDefaults(key: String) -> Bool
}
