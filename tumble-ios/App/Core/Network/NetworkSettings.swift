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
            scheme: "https", tumbleUrl: "tumble.hkr.se"
        )

        // Debug URL
        static let testing = NetworkSettings(
            scheme: "http", tumbleUrl: "localhost"
        )

    }

    let scheme: String
    let tumbleUrl: String
}
