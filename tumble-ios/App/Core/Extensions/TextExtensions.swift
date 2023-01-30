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
            .font(.system(size: 24, design: .rounded))
            .bold()
            .foregroundColor(Color("OnBackground"))
            .padding(.leading, 15)
    }
    
    func caption() -> some View {
        self
            .font(.system(size: 13, design: .rounded))
        
    }
    
    func titleInstructions() -> some View {
        self.font(.system(size: 18, design: .rounded))
            .padding(.bottom, 3)
    }
    
    func titleBody() -> some View {
        self.font(.system(size: 14, design: .rounded))
    }
    
    func titleSchool() -> some View {
        self.font(.system(size: 20, design: .rounded))
    }
    
    func featureText() -> some View {
        self.font(.system(size: 20, design: .rounded))
            .foregroundColor(Color("OnSurface"))
    }
    
    func onPrimaryMedium() -> some View {
        self.font(.system(size: 20, design: .rounded))
            .padding(8)
            .foregroundColor(Color("OnPrimary"))
    }
    
    func homePageOption() -> some View {
        self
            .font(.system(size: 17, design: .rounded))
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
        self.font(.system(size: 23, design: .rounded))
            .padding(.top, 20)
            .foregroundColor(Color("PrimaryColor"))
    }
    
    func subHeader() -> some View {
        self.font(.system(size: 22, design: .rounded))
            .padding([.leading, .trailing], 20)
    }
    
    func bottomBarItem(selectedTab: TabType, thisTab: TabType) -> some View {
        self.font(.system(size: 10, design: .rounded))
            .foregroundColor(selectedTab == thisTab ? Color("PrimaryColor") : Color("OnBackground"))
    }
    
    func info() -> some View {
        self.font(.system(size: 20, design: .rounded))
            .foregroundColor(Color("OnBackground"))
            .padding(.bottom, 25)
            .padding([.leading, .trailing], 15)
            .multilineTextAlignment(.center)
    }
    
    func programmeTitle() -> some View {
        self.font(.system(size: 18, design: .rounded))
            .multilineTextAlignment(.leading)
            .padding(.bottom, 10)
    }
    
    func programmeSubTitle() -> some View {
        self.font(.system(size: 14, design: .rounded))
            .multilineTextAlignment(.leading)
    }
    
    func searchResultsField() -> some View {
        self.font(.system(size: 16, design: .rounded))
            .padding(.leading, 20)
            .padding(.top, 20)
            .padding(.bottom, 10)
    }
    
    func backButton() -> some View {
        self.font(.system(size: 18, design: .rounded))
    }
    
    func timeSpanCard() -> some View {
        self.font(.system(size: 16, design: .rounded))
            .foregroundColor(Color("OnSurface"))
    }
    
    func titleCard() -> some View {
        self.font(.system(size: 24, design: .rounded))
            .foregroundColor(Color("OnSurface"))
            .padding(.leading, 25)
            .padding(.trailing, 25)
            .padding(.bottom, 2.5)
    }
    
    func courseNameCard() -> some View {
        self.font(.system(size: 18, design: .rounded))
            .foregroundColor(Color("OnSurface"))
            .padding(.leading, 25)
            .padding(.bottom, 10)
    }
    
    func locationCard() -> some View {
        self.font(.system(size: 18, design: .rounded))
            .foregroundColor(Color("OnSurface"))
    }
    
    func dayHeader() -> some View {
        self.font(.system(size: 24, design: .rounded))
            .padding(.trailing, 10)
    }

    func appVersionDrawer() -> some View {
        self.padding(.bottom, 30)
            .font(.system(size: 12, design: .rounded))
            .foregroundColor(Color("OnSurface"))
    }
    
}
