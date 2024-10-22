//
//  PreferenceStorable.swift
//  App
//
//  Created by Adis Veletanlic on 10/22/24.
//

import Foundation

protocol PreferenceStorable {
    associatedtype ValueType
    var key: SharedPreferenceKey { get }
    func get() -> ValueType
    func set(_ value: ValueType)
}
