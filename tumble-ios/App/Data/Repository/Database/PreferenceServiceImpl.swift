//
//  UserDefaultsService.swift
//  tumble-ios
//
//  Created by Adis Veletanlic on 11/16/22.
//

import Foundation
import SwiftUI

class PreferenceServiceImpl: PreferenceService {
    // ----------- SET -----------
    func setSchool(id: Int, closure: @escaping () -> Void) -> Void {
        UserDefaults.standard.set(id, forKey: StoreKey.school.rawValue)
        UserDefaults.standard.synchronize()
        closure()
    }
    
    func setUserOnboarded() -> Void {
        UserDefaults.standard.set(true, forKey: StoreKey.userOnboarded.rawValue)
        UserDefaults.standard.synchronize()
    }
    
    func setOffset(offset: Int) -> Void {
        UserDefaults.standard.set(offset, forKey: StoreKey.notifOffset.rawValue)
        UserDefaults.standard.synchronize()
    }
    
    func setBookmark(bookmark: String) -> Void {
        var bookmarks: [String] = UserDefaults.standard.object(forKey: StoreKey.bookmark.rawValue) as? [String] ?? []
        bookmarks.append(bookmark)
        UserDefaults.standard.set(bookmarks, forKey: StoreKey.bookmark.rawValue)
        UserDefaults.standard.synchronize()
    }
    
    func setLocale(locale: String) -> Void {
        UserDefaults.standard.set(locale, forKey: StoreKey.locale.rawValue)
        UserDefaults.standard.synchronize()
    }
    
    func setTheme(isDarkMode: Bool) -> Void {
        UserDefaults.standard.set(isDarkMode, forKey: StoreKey.theme.rawValue)
        UserDefaults.standard.set(true, forKey: StoreKey.overrideSystem.rawValue)
        UserDefaults.standard.synchronize()
    }
    
    func setOverrideSystemFalse() -> Void {
        UserDefaults.standard.set(false, forKey: StoreKey.overrideSystem.rawValue)
        UserDefaults.standard.synchronize()
    }
    
    func setLang(lang: String) -> Void {
        UserDefaults.standard.set(lang, forKey: StoreKey.lang.rawValue)
        UserDefaults.standard.synchronize()
    }
    
    func setNotifAllowed(notifAllowed: Bool) {
        UserDefaults.standard.set(notifAllowed, forKey: StoreKey.notifAllowed.rawValue)
        UserDefaults.standard.synchronize()
    }
    
    func setAutoSign(autoSign: Bool) {
        UserDefaults.standard.set(autoSign, forKey: StoreKey.autoSign.rawValue)
        UserDefaults.standard.synchronize()
    }
    
    func setViewType(viewType: Int) {
        UserDefaults.standard.set(viewType, forKey: StoreKey.viewType.rawValue)
        UserDefaults.standard.synchronize()
    }
    
    func setOverrideSystem(value: Bool) {
        UserDefaults.standard.set(value, forKey: StoreKey.overrideSystem.rawValue)
        UserDefaults.standard.synchronize()
    }
    
    
    // ----------- GET -----------
    func getDefault(key: String) -> Any? {
        return UserDefaults.standard.object(forKey: key)
    }
    
    func getDefaultViewType() -> ScheduleViewType {
        let hasView: Bool = self.isKeyPresentInUserDefaults(key: StoreKey.viewType.rawValue)
        if !(hasView) {
            self.setViewType(viewType: 0)
            return ScheduleViewType.allValues[0]
        }
        
        let viewType: Int = self.getDefault(key: StoreKey.viewType.rawValue) as! Int
        return ScheduleViewType.allValues[viewType]
    }
    
    func getDefaultSchool() -> School? {
        let id: Int = self.getDefault(key: StoreKey.school.rawValue) as? Int ?? -1
        if id == -1 {
            return nil
        }
        return schools.first(where: {$0.id == id})!
    }
    
    func isKeyPresentInUserDefaults(key: String) -> Bool {
        return UserDefaults.standard.object(forKey: key) != nil
    }
}
