//
//  ViewImageExtensions.swift
//  tumble-ios
//
//  Created by Adis Veletanlic on 2023-01-28.
//

import Foundation
import SwiftUI

extension Image {
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
        self.font(.system(size: 21))
            .frame(width: 19, height: 19)
            .foregroundColor(Color("OnPrimary"))
            .padding(15)
            .background(Color("PrimaryColor").opacity(95))
            .clipShape(RoundedRectangle(cornerRadius: 10))
    }
}
