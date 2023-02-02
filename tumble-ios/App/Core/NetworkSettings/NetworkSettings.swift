//
//  NetworkSettings.swift
//  tumble-ios
//
//  Created by Adis Veletanlic on 2023-01-29.
//

import Foundation


struct NetworkSettings {

    enum Environments {
        
        // Production URL
        static let production = NetworkSettings(
            port: 443, scheme: "https", tumbleUrl: "tumble.hkr.se"
        )

        // Debug URL
        static let testing = NetworkSettings(
            port: 7036, scheme: "https", tumbleUrl: "localhost"
        )

    }

    let port: Int
    let scheme: String
    let tumbleUrl: String
}
