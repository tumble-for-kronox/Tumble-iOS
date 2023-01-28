//
//  ViewFontExtensions.swift
//  tumble-ios
//
//  Created by Adis Veletanlic on 2023-01-28.
//

import Foundation
import SwiftUI

extension Text {
    
    func appHeader() -> some View {
        self
            .font(Font.custom("VarelaRound-Regular", size: 24))
            .foregroundColor(Color("OnBackground"))
            .padding(.leading, 15)
    }
    
    func caption() -> some View {
        self
            .font(Font.custom("VarelaRound-Regular", size: 12))
        
    }
    
    
    
    func titleInstructions() -> some View {
        self.font(.custom("VarelaRound-Regular", size: 18))
            .padding(.bottom, 3)
    }
    
    func titleBody() -> some View {
        self.font(.custom("VarelaRound-Regular", size: 14))
    }
    
    func titleSchool() -> some View {
        self.font(.custom("VarelaRound-Regular", size: 20))
    }
    
    func featureText() -> some View {
        self.font(Font.custom("VarelaRound-Regular", size: 20))
            .foregroundColor(Color("OnSurface"))
    }
    
    func onPrimaryMedium() -> some View {
        self.font(.custom("VarelaRound-Regular", size: 20))
        .padding(8)
        .foregroundColor(Color("OnPrimary"))
    }
    
    func homePageOption() -> some View {
        self
            .font(Font.custom("VarelaRound-Regular", size: 17))
            .foregroundColor(Color("OnSurface"))
            .padding(.trailing, 15)
            .padding(.leading, 15)
    }
    
    func dayOfWeek() -> some View {
        self.frame(maxWidth: .infinity)
            .padding(.top, 1)
            .lineLimit(1)
    }
    
    func mainheader() -> some View {
        self.font(Font.custom("VarelaRound-Regular", size: 23))
            .padding(.top, 20)
            .foregroundColor(Color("PrimaryColor"))
    }
    
    func subHeader() -> some View {
        self.font(Font.custom("VarelaRound-Regular", size: 22))
        .padding([.leading, .trailing], 20)
    }
    
    func bottomBarItem(selectedTab: TabType, thisTab: TabType) -> some View {
        self.font(.custom("VarelaRound-Regular", size: 10))
            .foregroundColor(selectedTab == thisTab ? Color("PrimaryColor") : Color("OnBackground"))
    }
}
