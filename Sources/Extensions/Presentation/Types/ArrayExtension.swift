//
//  ArrayExtension.swift
//  tumble-ios
//
//  Created by Adis Veletanlic on 2023-03-21.
//

import Foundation

extension Array {
    func pick(from: Int = 0, length: Int) -> [Element] {
        precondition(length >= 0, "length must not be negative")
        if length >= count { return self }
        let oldMax = Double(count - from - 1)
        let newMax = Double(length - 1)
        return (0..<length).map { self[from + Int((Double($0) * oldMax / newMax).rounded())] }
    }
}
