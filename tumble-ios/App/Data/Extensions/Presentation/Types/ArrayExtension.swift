//
//  ArrayExtension.swift
//  tumble-ios
//
//  Created by Adis Veletanlic on 2023-03-21.
//

import Foundation

extension Array  {

    /// source: https://stackoverflow.com/questions/58873352/swift-get-x-number-of-elements-from-an-array
    /// Return a smaller array by picking “evenly distributed” elements.
    ///
    /// - Parameter length: The desired array length
    /// - Returns: An array with `length` elements from `self`

    func pick(length: Int) -> [Element]  {
        precondition(length >= 0, "length must not be negative")
        if length >= count { return self }
        let oldMax = Double(count - 1)
        let newMax = Double(length - 1)
        return (0..<length).map { self[Int((Double($0) * oldMax / newMax).rounded())] }
    }
}
