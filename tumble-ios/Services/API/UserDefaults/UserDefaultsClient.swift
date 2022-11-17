//
//  UserDefaultsService.swift
//  tumble-ios
//
//  Created by Adis Veletanlic on 11/16/22.
//

import Foundation

extension UserDefaults {
    
    
    // ----------- SET -----------
    public func setSchool(id: Int) -> Void {
        UserDefaults.standard.set(id, forKey: "SCHOOL")
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
    
    public func setTheme(theme: String) -> Void {
        UserDefaults.standard.set(theme, forKey: StoreKey.theme.rawValue)
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
    
    
    // ----------- GET -----------
    func getDefault(key: String) -> Any? {
        return UserDefaults.standard.object(forKey: key)
    }
    
    enum StoreKey: String {
        case school
        case bookmark
        case theme
        case lang
        case notifAllowed
        case notifOffset
        case locale
        case autoSign
        
        var key: String {
            switch self {
            case .school:
                return "SCHOOL"
            case .bookmark:
                return "BOOKMARK"
            case .theme:
                return "THEME"
            case .lang:
                return "LANG"
            case .notifAllowed:
                return "NOTIF_ALLOW"
            case .notifOffset:
                return "NOTIF_OFFSET"
            case .locale:
                return "LOCALE"
            case .autoSign:
                return "AUTO_SIGN"
            }
        }
    }
}
