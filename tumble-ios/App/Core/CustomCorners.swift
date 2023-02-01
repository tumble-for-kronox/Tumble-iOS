//
//  CustomCorners.swift
//  tumble-ios
//
//  Created by Adis Veletanlic on 2023-02-01.
//

import Foundation
import SwiftUI
import UIKit

struct CustomCorners: Shape {
    var corners: UIRectCorner
    var radius: CGFloat
    
    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(roundedRect: rect, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        return Path(path.cgPath)
    }
}
