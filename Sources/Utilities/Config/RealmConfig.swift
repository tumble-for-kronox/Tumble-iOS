//
//  RealmConfig.swift
//  Tumble
//
//  Created by Adis Veletanlic on 4/24/23.
//

import Foundation
import RealmSwift

var realmConfig: Realm.Configuration {
    let container = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: "group.com.example.tumble")
    let realmURL = container?.appendingPathComponent("realm.db")
    let config = Realm.Configuration(fileURL: realmURL, schemaVersion: 1)
    return config
}
