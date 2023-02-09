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
    
    func toHex() -> String {
        let components = self.components()
        let r = Int(components.r * 255)
        let g = Int(components.g * 255)
        let b = Int(components.b * 255)
        return String(format: "#%02X%02X%02X", r, g, b)
    }
    
    private func components() -> (r: Double, g: Double, b: Double) {
        let scanner = Scanner(string: self.description.trimmingCharacters(in: CharacterSet.alphanumerics.inverted))
        var hexNumber: UInt64 = 0
        var r: Double = 0.0, g: Double = 0.0, b: Double = 0.0
        scanner.scanHexInt64(&hexNumber)
        
        r = Double((hexNumber & 0xff000000) >> 24) / 255
        g = Double((hexNumber & 0x00ff0000) >> 16) / 255
        b = Double((hexNumber & 0x0000ff00) >> 8) / 255
        
        return (r, g, b)
    }
}
