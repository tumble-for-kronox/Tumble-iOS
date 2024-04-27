//
//  UserDefaultsService.swift
//  Tumble
//
//  Created by Adis Veletanlic on 11/16/22.
//

import Foundation
import SwiftUI

class PreferenceService {
    @Published var userOnBoarded: Bool = false
    @Published var authSchoolId: Int = -1
    @Published var autoSignupEnabled: Bool = false
    
    init() {
        authSchoolId = getDefaultAuthSchool() ?? -1
        userOnBoarded = isKeyPresentInUserDefaults(key: StoreKey.userOnboarded.rawValue)
        autoSignupEnabled = getAutoSignup()
    }
    
    // ----------- SET -----------
    func setAuthSchool(id: Int) {
        authSchoolId = id
        UserDefaults.standard.set(id, forKey: StoreKey.authSchool.rawValue)
        UserDefaults.standard.synchronize()
    }
    
    func setUserOnboarded() {
        UserDefaults.standard.set(true, forKey: StoreKey.userOnboarded.rawValue)
        userOnBoarded = true
        UserDefaults.standard.synchronize()
    }
    
    func setOffset(offset: Int) {
        UserDefaults.standard.set(offset, forKey: StoreKey.notificationOffset.rawValue)
        UserDefaults.standard.synchronize()
    }
    
    func setAppearance(appearance: String) {
        UserDefaults.standard.set(appearance, forKey: StoreKey.appearance.rawValue)
        UserDefaults.standard.synchronize()
    }
    
    func setLang(lang: String) {
        UserDefaults.standard.set(lang, forKey: StoreKey.locale.rawValue)
        UserDefaults.standard.synchronize()
    }
    
    func setAutoSignup(autoSignup: Bool) {
        autoSignupEnabled = autoSignup
        UserDefaults.standard.set(autoSignup, forKey: StoreKey.autoSignup.rawValue)
        UserDefaults.standard.synchronize()
    }
    
    func setViewType(viewType: Int) {
        UserDefaults.standard.set(viewType, forKey: StoreKey.viewType.rawValue)
        UserDefaults.standard.synchronize()
    }
    
    func setLastUpdated(time: Date) {
        UserDefaults.standard.set(time, forKey: StoreKey.lastUpdated.rawValue)
        UserDefaults.standard.synchronize()
    }
    
    func setShowOneTimePopup(show: Bool = false) {
        UserDefaults.standard.set(show, forKey: StoreKey.showOneTimePopup.rawValue)
        UserDefaults.standard.synchronize()
    }
    
    // ----------- GET -----------
    func getDefault(key: String) -> Any? {
        return UserDefaults.standard.object(forKey: key)
    }
    
    func getLastUpdated() -> Date? {
        return UserDefaults.standard.object(forKey: StoreKey.lastUpdated.rawValue) as? Date
    }
    
    func showOneTimePopup() -> Bool {
        return UserDefaults.standard.object(forKey: StoreKey.showOneTimePopup.rawValue) as? Bool ?? true
    }
    
    func getDefaultViewType() -> ViewType {
        let hasView: Bool = isKeyPresentInUserDefaults(key: StoreKey.viewType.rawValue)
        if !hasView {
            setViewType(viewType: 0)
            return ViewType.allCases[0]
        }
        
        let viewType: Int = getDefault(key: StoreKey.viewType.rawValue) as! Int
        return ViewType.allCases[viewType]
    }
    
    func getDefaultAuthSchoolName(schools: [School]) -> String {
        return schools.first(where: { $0.id == authSchoolId })!.name
    }
    
    func getDefaultAuthSchool() -> Int? {
        let id: Int = UserDefaults.standard.object(forKey: StoreKey.authSchool.rawValue) as? Int ?? -1
        if id == -1 {
            return nil
        }
        return id
    }
    
    func getNotificationOffset() -> Int {
        let hasOffset: Bool = isKeyPresentInUserDefaults(key: StoreKey.notificationOffset.rawValue)
        if !hasOffset {
            setOffset(offset: 60)
            return 60
        }
        return getDefault(key: StoreKey.notificationOffset.rawValue) as! Int
    }
    
    func getAutoSignup() -> Bool {
        if let autoSignup = getDefault(key: StoreKey.autoSignup.rawValue) as? Bool {
            return autoSignup
        }
        return false
    }
    
    func isKeyPresentInUserDefaults(key: String) -> Bool {
        return UserDefaults.standard.object(forKey: key) != nil
    }
}
