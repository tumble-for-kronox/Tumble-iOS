//
//  ViewImageExtensions.swift
//  Tumble
//
//  Created by Adis Veletanlic on 2023-01-28.
//

import Foundation
import SwiftUI

extension Image {
    func tabBarIcon(isSelected: Bool) -> some View {
        font(.system(size: 22, weight: .medium))
            .foregroundColor(isSelected ? .primary : .onSurface.opacity(0.5))
            .padding(.bottom, 5)
    }
    
    func actionIcon() -> some View {
        font(.system(size: 17, weight: .medium))
            .foregroundColor(.primary)
    }
    
    func featureIcon() -> some View {
        font(.system(size: 20))
            .foregroundColor(Color("PrimaryColor"))
    }
}
