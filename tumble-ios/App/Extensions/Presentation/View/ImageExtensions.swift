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
            .font(.system(size: 21))
            .foregroundColor(isSelected ? .primary : .onSurface.opacity(0.5))
    }
    
    func navBarIcon() -> some View {
        self
            .font(.system(size: 17))
            .foregroundColor(.onBackground.opacity(0.8))
    }
    
    func featureIcon() -> some View {
        self.font(.system(size: 20))
            .foregroundColor(Color("PrimaryColor"))
    }
    
    
}
