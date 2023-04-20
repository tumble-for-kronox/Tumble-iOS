//
//  TumbleUser.swift
//  tumble-ios
//
//  Created by Adis Veletanlic on 2023-04-01.
//

import Foundation

class TumbleUser: Decodable, Encodable {
    var username: String
    var password: String
    var name: String
    
    init(username: String, password: String, name: String) {
        self.username = username
        self.password = password
        self.name = name
    }
}
