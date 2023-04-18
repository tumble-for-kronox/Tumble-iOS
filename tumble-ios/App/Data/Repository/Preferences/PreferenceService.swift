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
    @Published var schoolId: Int = -1
    
    init() {
        self.schoolId = self.getDefaultSchool() ?? -1
        self.userOnBoarded = self.isKeyPresentInUserDefaults(key: StoreKey.userOnboarded.rawValue)
    }
    
    // ----------- SET -----------
    func setSchool(id: Int) -> Void {
        schoolId = id
        UserDefaults.standard.set(id, forKey: StoreKey.school.rawValue)
        UserDefaults.standard.synchronize()
    }
    
    func setUserOnboarded() -> Void {
        UserDefaults.standard.set(true, forKey: StoreKey.userOnboarded.rawValue)
        userOnBoarded = true
        UserDefaults.standard.synchronize()
    }
    
    func setOffset(offset: Int) -> Void {
        UserDefaults.standard.set(offset, forKey: StoreKey.notificationOffset.rawValue)
        UserDefaults.standard.synchronize()
    }
    
    func setAppearance(appearance: String) -> Void {
        UserDefaults.standard.set(appearance, forKey: StoreKey.appearance.rawValue)
        UserDefaults.standard.synchronize()
    }
    
    func setLang(lang: String) -> Void {
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
        let hasView: Bool = self.isKeyPresentInUserDefaults(key: StoreKey.viewType.rawValue)
        if !(hasView) {
            self.setViewType(viewType: 0)
            return BookmarksViewType.allValues[0]
        }
        
        let viewType: Int = self.getDefault(key: StoreKey.viewType.rawValue) as! Int
        return BookmarksViewType.allValues[viewType]
    }
    
    func getDefaultSchoolName(schools: [School]) -> String {
        return schools.first(where: {$0.id == schoolId})!.name
    }
    
    func getDefaultSchool() -> Int? {
        let id: Int = UserDefaults.standard.object(forKey: StoreKey.school.rawValue) as? Int ?? -1
        if id == -1 {
            return nil
        }
        return id
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
    
    func getUniversityName(schools: [School]) -> String {
        let schoolName: String = schools.first(where: {$0.id == schoolId})!.name
        return schoolName
    }
    
    func getUniversityColor(schools: [School]) -> Color {
        let school: School? = schools.first(where: { $0.id == schoolId })
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
