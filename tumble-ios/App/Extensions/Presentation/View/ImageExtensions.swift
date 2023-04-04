//
//  ViewImageExtensions.swift
//  tumble-ios
//
//  Created by Adis Veletanlic on 2023-01-28.
//

import Foundation
import SwiftUI

extension Image {
    
    func tabBarIcon(isSelected: Bool) -> some View {
        self
            .font(.system(size: 21, weight: .medium))
            .foregroundColor(isSelected ? .primary : .onSurface.opacity(0.5))
    }
    
    func actionIcon() -> some View {
        self
            .font(.system(size: 17, weight: .medium))
            .foregroundColor(.onBackground)
    }
    
    func featureIcon() -> some View {
        self.font(.system(size: 20))
            .foregroundColor(Color("PrimaryColor"))
    }
    
    
}
