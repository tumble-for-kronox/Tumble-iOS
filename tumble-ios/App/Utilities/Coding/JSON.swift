//
//  JSON.swift
//  tumble-ios
//
//  Created by Adis Veletanlic on 2023-04-01.
//

import Foundation

extension JSONEncoder {
    static let shared: JSONEncoder = JSONEncoder()
}

extension JSONDecoder {
    static let shared: JSONDecoder = JSONDecoder()
}
