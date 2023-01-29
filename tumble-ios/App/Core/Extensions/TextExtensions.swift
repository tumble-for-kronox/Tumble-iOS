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
            .font(Font.custom("Montserrat-Regular", size: 24))
            .foregroundColor(Color("OnBackground"))
            .padding(.leading, 15)
    }
    
    func caption() -> some View {
        self
            .font(Font.custom("Montserrat-Regular", size: 12))
        
    }
    
    
    
    func titleInstructions() -> some View {
        self.font(.custom("Montserrat-Regular", size: 18))
            .padding(.bottom, 3)
    }
    
    func titleBody() -> some View {
        self.font(.custom("Montserrat-Regular", size: 14))
    }
    
    func titleSchool() -> some View {
        self.font(.custom("Montserrat-Regular", size: 20))
    }
    
    func featureText() -> some View {
        self.font(Font.custom("Montserrat-Regular", size: 20))
            .foregroundColor(Color("OnSurface"))
    }
    
    func onPrimaryMedium() -> some View {
        self.font(.custom("Montserrat-Regular", size: 20))
            .padding(8)
            .foregroundColor(Color("OnPrimary"))
    }
    
    func homePageOption() -> some View {
        self
            .font(Font.custom("Montserrat-Regular", size: 17))
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
        self.font(Font.custom("Montserrat-Regular", size: 23))
            .padding(.top, 20)
            .foregroundColor(Color("PrimaryColor"))
    }
    
    func subHeader() -> some View {
        self.font(Font.custom("Montserrat-Regular", size: 22))
            .padding([.leading, .trailing], 20)
    }
    
    func bottomBarItem(selectedTab: TabType, thisTab: TabType) -> some View {
        self.font(.custom("Montserrat-Regular", size: 10))
            .foregroundColor(selectedTab == thisTab ? Color("PrimaryColor") : Color("OnBackground"))
    }
    
    func info() -> some View {
        self.font(.custom("Montserrat-Regular", size: 20))
            .foregroundColor(Color("OnBackground"))
            .padding(.bottom, 25)
            .padding([.leading, .trailing], 15)
            .multilineTextAlignment(.center)
    }
    
    func programmeTitle() -> some View {
        self.font(.custom("Montserrat-Regular", size: 18))
            .multilineTextAlignment(.leading)
            .padding(.bottom, 10)
    }
    
    func programmeSubTitle() -> some View {
        self.font(.custom("Montserrat-Regular", size: 14))
            .multilineTextAlignment(.leading)
    }
    
    func searchResultsField() -> some View {
        self.font(.custom("Montserrat-Regular", size: 16))
            .padding(.leading, 20)
            .padding(.top, 20)
            .padding(.bottom, 10)
    }
    
    func backButton() -> some View {
        self.font(.custom("Montserrat-Regular", size: 18))
    }
    
    func timeSpanCard() -> some View {
        self.font(.custom("Montserrat-Regular", size: 16))
            .foregroundColor(Color("OnSurface"))
    }
    
    func titleCard() -> some View {
        self.font(.custom("Montserrat-Regular", size: 24))
            .foregroundColor(Color("OnSurface"))
            .padding(.leading, 25)
            .padding(.trailing, 25)
            .padding(.bottom, 2.5)
    }
    
    func courseNameCard() -> some View {
        self.font(.custom("Montserrat-Regular", size: 18))
            .foregroundColor(Color("OnSurface"))
            .padding(.leading, 25)
            .padding(.bottom, 10)
    }
    
    func locationCard() -> some View {
        self.font(.custom("Montserrat-RegularFont_wght", size: 18))
            .foregroundColor(Color("OnSurface"))
    }
    
    func dayHeader() -> some View {
        self.font(.custom("Montserrat-Regular", size: 24))
            .padding(.trailing, 10)
    }

    func appVersionDrawer() -> some View {
        self.padding(.bottom, 30)
            .font(.custom("Montserrat-Regular", size: 12))
            .foregroundColor(Color("OnSurface"))
    }
    
}
