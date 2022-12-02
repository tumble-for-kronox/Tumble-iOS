//
//  UserDefaultsService.swift
//  tumble-ios
//
//  Created by Adis Veletanlic on 11/16/22.
//

import Foundation
import SwiftUI

extension UserDefaults {
    
    
    // ----------- SET -----------
    public func setSchool(id: Int) -> Void {
        UserDefaults.standard.set(id, forKey: StoreKey.school.rawValue)
        UserDefaults.standard.synchronize()
    }
    
    public func setUserOnboarded() -> Void {
        UserDefaults.standard.set(true, forKey: StoreKey.userOnboarded.rawValue)
        UserDefaults.standard.synchronize()
    }
    
    public func setOffset(offset: Int) -> Void {
        UserDefaults.standard.set(offset, forKey: StoreKey.notifOffset.rawValue)
        UserDefaults.standard.synchronize()
    }
    
    public func setBookmark(bookmark: String) -> Void {
        var bookmarks: [String] = UserDefaults.standard.object(forKey: StoreKey.bookmark.rawValue) as? [String] ?? []
        bookmarks.append(bookmark)
        UserDefaults.standard.set(bookmarks, forKey: StoreKey.bookmark.rawValue)
        UserDefaults.standard.synchronize()
    }
    
    public func setLocale(locale: String) -> Void {
        UserDefaults.standard.set(locale, forKey: StoreKey.locale.rawValue)
        UserDefaults.standard.synchronize()
    }
    
    public func setTheme(isDarkMode: Bool) -> Void {
        UserDefaults.standard.set(isDarkMode, forKey: StoreKey.theme.rawValue)
        UserDefaults.standard.set(true, forKey: StoreKey.overrideSystem.rawValue)
        UserDefaults.standard.synchronize()
    }
    
    public func setOverrideSystemFalse() -> Void {
        UserDefaults.standard.set(false, forKey: StoreKey.overrideSystem.rawValue)
        UserDefaults.standard.synchronize()
    }
    
    public func setLang(lang: String) -> Void {
        UserDefaults.standard.set(lang, forKey: StoreKey.lang.rawValue)
        UserDefaults.standard.synchronize()
    }
    
    public func setNotifAllowed(notifAllowed: Bool) {
        UserDefaults.standard.set(notifAllowed, forKey: StoreKey.notifAllowed.rawValue)
        UserDefaults.standard.synchronize()
    }
    
    public func setAutoSign(autoSign: Bool) {
        UserDefaults.standard.set(autoSign, forKey: StoreKey.autoSign.rawValue)
        UserDefaults.standard.synchronize()
    }
    
    public func setViewType(viewType: Int) {
        UserDefaults.standard.set(viewType, forKey: StoreKey.viewType.rawValue)
        UserDefaults.standard.synchronize()
    }
    
    public func setOverrideSystem(value: Bool) {
        UserDefaults.standard.set(value, forKey: StoreKey.overrideSystem.rawValue)
        UserDefaults.standard.synchronize()
    }
    
    
    // ----------- GET -----------
    func getDefault(key: String) -> Any? {
        return UserDefaults.standard.object(forKey: key)
    }
    
    func getDefaultSchool() -> School {
        let id: Int = UserDefaults.standard.getDefault(key: UserDefaults.StoreKey.school.rawValue) as! Int
        return schools.first(where: {$0.id == id})!
    }
    
    func isKeyPresentInUserDefaults(key: String) -> Bool {
        return UserDefaults.standard.object(forKey: key) != nil
    }
    
    enum StoreKey: String {
        case school = "SCHOOL"
        case bookmark = "BOOKMARK"
        case theme = "THEME"
        case lang = "LANG"
        case notifAllowed = "NOTIF_ALLOW"
        case notifOffset = "NOTIF_OFFSET"
        case locale = "LOCALE"
        case autoSign = "AUTO_SIGN"
        case viewType = "VIEW"
        case userOnboarded = "USER_ONBOARDED"
        case overrideSystem = "OVERRIDE_THEME"
    }
}
