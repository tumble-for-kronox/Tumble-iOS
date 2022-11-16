//
//  School.swift
//  tumble-ios
//
//  Created by Adis Veletanlic on 11/16/22.
//

import Foundation
import SwiftUI

struct School: Hashable, Codable, Identifiable {
    let id: Int
    let url: String
    let name: String
    let loginRq: Bool
    
    private var logoName: String
    var logo: Image {
        Image(logoName)
    }
}
