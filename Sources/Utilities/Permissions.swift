//
//  Permissions.swift
//  Tumble
//
//  Created by Adis Veletanlic on 4/15/23.
//

import Foundation

func getDemoUserCredentials() -> (username: String, password: String)? {
    guard let username = ProcessInfo.processInfo.environment["DEMO_USERNAME"],
          let password = ProcessInfo.processInfo.environment["DEMO_PASSWORD"] else {
        return nil
    }
    return (username, password)
}
