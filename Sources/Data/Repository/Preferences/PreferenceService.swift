//
//  UserDefaultsService.swift
//  tumble-ios
//
//  Created by Adis Veletanlic on 11/16/22.
//

import Foundation
import SwiftUI

class PreferenceService: PreferenceServiceProtocol {
    @Published var userOnBoarded: Bool = false
    @Published var authSchoolId: Int = -1
    
    init() {
        authSchoolId = getDefaultAuthSchool() ?? -1
        userOnBoarded = isKeyPresentInUserDefaults(key: StoreKey.userOnboarded.rawValue)
    }
    
    // ----------- SET -----------
    func setAuthSchool(id: Int) {
        authSchoolId = id
        UserDefaults.standard.set(id, forKey: StoreKey.school.rawValue)
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
        UserDefaults.standard.set(autoSignup, forKey: StoreKey.autoSignup.rawValue)
        UserDefaults.standard.synchronize()
    }
    
    func setViewType(viewType: Int) {
        UserDefaults.standard.set(viewType, forKey: StoreKey.viewType.rawValue)
        UserDefaults.standard.synchronize()
    }
    
    // ----------- GET -----------
    func getDefault(key: String) -> Any? {
        return UserDefaults.standard.object(forKey: key)
    }
    
    func getDefaultViewType() -> BookmarksViewType {
        let hasView: Bool = isKeyPresentInUserDefaults(key: StoreKey.viewType.rawValue)
        if !hasView {
            setViewType(viewType: 0)
            return BookmarksViewType.allValues[0]
        }
        
        let viewType: Int = getDefault(key: StoreKey.viewType.rawValue) as! Int
        return BookmarksViewType.allValues[viewType]
    }
    
    func getDefaultAuthSchoolName(schools: [School]) -> String {
        return schools.first(where: { $0.id == authSchoolId })!.name
    }
    
    func getDefaultAuthSchool() -> Int? {
        let id: Int = UserDefaults.standard.object(forKey: StoreKey.school.rawValue) as? Int ?? -1
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
    
    func isKeyPresentInUserDefaults(key: String) -> Bool {
        return UserDefaults.standard.object(forKey: key) != nil
    }
    
    func getUniversityName(schools: [School]) -> String {
        let schoolName: String = schools.first(where: { $0.id == authSchoolId })!.name
        return schoolName
    }
    
    func getUniversityColor(schools: [School]) -> Color {
        let school: School? = schools.first(where: { $0.id == authSchoolId })
        let uniColor: Color
        
        switch school?.color {
        case "blue":
            uniColor = Color.blue
        case "orange":
            uniColor = Color.orange
        case "green":
            uniColor = Color.green
        case "yellow":
            uniColor = Color.yellow
        case "brown":
            uniColor = Color.brown
        case "red":
            uniColor = Color.red
        default:
            uniColor = Color.black
        }

        return uniColor
    }
}
