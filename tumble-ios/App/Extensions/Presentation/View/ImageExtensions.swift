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
            .font(.system(size: 22))
            .foregroundColor(isSelected ? .primary : .onBackground.opacity(0.8))
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
    
    func homePageOptionIcon(color: Color) -> some View {
        self
            .font(.system(size: 20))
            .frame(width: 17, height: 17)
            .padding(15)
            .foregroundColor(Color("OnPrimary"))
            .background(color)
            .clipShape(RoundedRectangle(cornerRadius: 7.5))
    }
    
    func optionBigIcon() -> some View {
        self.font(.system(size: 24))
            .padding(.trailing, 24)
            .foregroundColor(Color("OnBackground"))
    }
    
    func drawerIcon() -> some View {
        self.font(.system(size: 18))
            .frame(width: 15, height: 15)
            .foregroundColor(.background)
            .padding(5)
            .background(Color.onBackground)
            .clipShape(RoundedRectangle(cornerRadius: 10))
    }
}
