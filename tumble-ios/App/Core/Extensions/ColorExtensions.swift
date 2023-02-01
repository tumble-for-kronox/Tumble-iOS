//
//  ColorExtensions.swift
//  tumble-ios
//
//  Created by Adis Veletanlic on 2023-01-31.
//

import Foundation
import SwiftUI

extension Color {
    static let primary      = Color("PrimaryColor")
    static let onPrimary    = Color("OnPrimary")
    static let secondary    = Color("SecondaryColor")
    static let background   = Color("BackgroundColor")
    static let onBackground = Color("OnBackground")
    static let surface      = Color("SurfaceColor")
    static let onSurface    = Color("OnSurface")
    static let contrast     = Color("ContrastColor")
    static let dark         = Color("Dark")
    static let bright       = Color("Bright")
    
    // Source
    // https://stackoverflow.com/questions/64071466/detect-color-type-dark-or-light
    func isDarkBackground(color: Color) -> Bool {
            var r, g, b, a: CGFloat
            (r, g, b, a) = (0, 0, 0, 0)
            UIColor(color).getRed(&r, green: &g, blue: &b, alpha: &a)
            let luminance = 0.2126 * r + 0.7152 * g + 0.0722 * b
            return luminance < 0.50

        }
}
