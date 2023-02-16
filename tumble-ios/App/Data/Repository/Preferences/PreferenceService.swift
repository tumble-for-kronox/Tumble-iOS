//
//  UserDefaultsService.swift
//  tumble-ios
//
//  Created by Adis Veletanlic on 11/16/22.
//

import Foundation
import SwiftUI

class PreferenceService: PreferenceServiceProtocol {
    
    func toggleBookmark(bookmark: String, value: Bool) {
        var bookmarks: [String : Bool] = UserDefaults.standard.object(forKey: StoreKey.bookmarks.rawValue) as? [String : Bool] ?? [:]
        bookmarks[bookmark] = value
        UserDefaults.standard.set(bookmarks, forKey: StoreKey.bookmarks.rawValue)
        UserDefaults.standard.synchronize()
    }
    
    // ----------- SET -----------
    func setSchool(id: Int, closure: @escaping () -> Void) -> Void {
        UserDefaults.standard.set(id, forKey: StoreKey.school.rawValue)
        UserDefaults.standard.synchronize()
        closure()
    }
    
    func setProfileImage(image: UIImage?, forKey key: String = StoreKey.profileImage.rawValue) {
        if let data = image?.jpegData(compressionQuality: 10.0) {
            UserDefaults.standard.set(data, forKey: key)
        } else {
            UserDefaults.standard.set(nil, forKey: key)
        }
        UserDefaults.standard.synchronize()
    }
    
    func setBookmarks(bookmarks: [Bookmark]) {
        UserDefaults.standard.set(Dictionary(uniqueKeysWithValues: bookmarks.map { ($0.id, $0.toggled) }), forKey: StoreKey.bookmarks.rawValue)
        UserDefaults.standard.synchronize()
    }
    
    func setUserOnboarded() -> Void {
        UserDefaults.standard.set(true, forKey: StoreKey.userOnboarded.rawValue)
        UserDefaults.standard.synchronize()
    }
    
    func setOffset(offset: Int) -> Void {
        UserDefaults.standard.set(offset, forKey: StoreKey.notificationOffset.rawValue)
        UserDefaults.standard.synchronize()
    }
    
    func setBookmarks(bookmark: String) -> Void {
        var bookmarks: [String : Bool] = UserDefaults.standard.object(forKey: StoreKey.bookmarks.rawValue) as? [String : Bool] ?? [:]
        bookmarks[bookmark] = true
        UserDefaults.standard.set(bookmarks, forKey: StoreKey.bookmarks.rawValue)
        UserDefaults.standard.synchronize()
    }
    
    func setTheme(isDarkMode: Bool) -> Void {
        UserDefaults.standard.set(isDarkMode, forKey: StoreKey.theme.rawValue)
        UserDefaults.standard.set(true, forKey: StoreKey.overrideSystemTheme.rawValue)
        UserDefaults.standard.synchronize()
    }
    
    func setOverrideSystemFalse() -> Void {
        UserDefaults.standard.set(false, forKey: StoreKey.overrideSystemTheme.rawValue)
        UserDefaults.standard.synchronize()
    }
    
    func setLang(lang: String) -> Void {
        UserDefaults.standard.set(lang, forKey: StoreKey.language.rawValue)
        UserDefaults.standard.synchronize()
    }
    
    func setAutoSignup(autoSignup: Bool) {
        UserDefaults.standard.set(autoSignup, forKey: StoreKey.autoSignup.rawValue)
        UserDefaults.standard.synchronize()
    }
    
    func setViewType(viewType: Int) {
        UserDefaults.standard.set(viewType, forKey: StoreKey.viewType.rawValue)
        UserDefaults.standard.synchronize()
    }
    
    func setOverrideSystem(value: Bool) {
        UserDefaults.standard.set(value, forKey: StoreKey.overrideSystemTheme.rawValue)
        UserDefaults.standard.synchronize()
    }
    
    
    // ----------- GET -----------
    func getDefault(key: String) -> Any? {
        return UserDefaults.standard.object(forKey: key)
    }
    
    func loadImage(key: String = StoreKey.profileImage.rawValue) -> UIImage? {
        if let data = UserDefaults.standard.data(forKey: key) {
            return UIImage(data: data)
        }
        return nil
    }
    
    func getBookmarks() -> [Bookmark]? {
        let dict: [String : Bool] = UserDefaults.standard.object(forKey: StoreKey.bookmarks.rawValue) as? [String : Bool] ?? [:]
        return dict.map{ Bookmark(toggled: $0.value, id: $0.key) }
    }
    
    func getDefaultViewType() -> BookmarksViewType {
        let hasView: Bool = self.isKeyPresentInUserDefaults(key: StoreKey.viewType.rawValue)
        if !(hasView) {
            self.setViewType(viewType: 0)
            return BookmarksViewType.allValues[0]
        }
        
        let viewType: Int = self.getDefault(key: StoreKey.viewType.rawValue) as! Int
        return BookmarksViewType.allValues[viewType]
    }
    
    func getDefaultSchool() -> School? {
        let id: Int = self.getDefault(key: StoreKey.school.rawValue) as? Int ?? -1
        if id == -1 {
            return nil
        }
        return schools.first(where: {$0.id == id})!
    }
    
    func getNotificationOffset() -> Int {
        let hasOffset: Bool = self.isKeyPresentInUserDefaults(key: StoreKey.notificationOffset.rawValue)
        if !hasOffset {
            self.setOffset(offset: 60)
            return 60
        }
        return self.getDefault(key: StoreKey.notificationOffset.rawValue) as! Int
    }
    
    func isKeyPresentInUserDefaults(key: String) -> Bool {
        return UserDefaults.standard.object(forKey: key) != nil
    }
}
