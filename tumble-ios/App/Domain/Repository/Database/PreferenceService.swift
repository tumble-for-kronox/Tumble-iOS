//
//  DatabaseRepository.swift
//  tumble-ios
//
//  Created by Adis Veletanlic on 2023-01-27.
//

import Foundation

protocol PreferenceService {
    // ----------- SET -----------
    func setSchool(id: Int) -> Void
    
    func setUserOnboarded() -> Void
    
    func setOffset(offset: Int) -> Void
    
    func setBookmark(bookmark: String) -> Void
    
    func setLocale(locale: String) -> Void
    
    func setTheme(isDarkMode: Bool) -> Void
    
    func setOverrideSystemFalse() -> Void
    
    func setLang(lang: String) -> Void
    
    func setNotifAllowed(notifAllowed: Bool)
    
    func setAutoSign(autoSign: Bool)
    
    func setViewType(viewType: Int)
    
    func setOverrideSystem(value: Bool)
    
    
    // ----------- GET -----------
    func getDefault(key: String) -> Any?
    
    func getDefaultViewType() -> ScheduleViewType
    
    func getDefaultSchool() -> School?
    
    func isKeyPresentInUserDefaults(key: String) -> Bool
}
