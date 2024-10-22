//
//  LocalePreference.swift
//  Tumble
//
//  Created by Adis Veletanlic on 10/22/24.
//

import Foundation

class AutoSignupPreference: PreferenceStorable {
    typealias ValueType = Bool
    var key: SharedPreferenceKey = .autoSignup
    
    func get() -> Bool {
        return UserDefaults.standard.bool(forKey: key.rawValue)
    }
    
    func set(_ value: Bool) {
        UserDefaults.standard.set(value, forKey: key.rawValue)
    }
}
