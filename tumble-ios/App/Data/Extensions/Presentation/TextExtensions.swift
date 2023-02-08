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
            .foregroundColor(.onBackground)
            .padding(.leading, 15)
    }
    
    func caption() -> some View {
        self
            .font(.system(size: 13, design: .rounded))
    }

    func onSurfaceSmall() -> some View {
        self
            .font(.system(size: 15))
            .foregroundColor(.onSurface)
    }
    
    func titleInstructions() -> some View {
        self.font(.system(size: 18, design: .rounded))
            .bold()
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
            .foregroundColor(.onSurface)
    }
    
    func onPrimaryMedium() -> some View {
        self.font(.system(size: 20, design: .rounded))
            .padding(8)
            .foregroundColor(.onPrimary)
    }
    
    func onPrimaryMediumBold() -> some View {
        self.font(.system(size: 20, design: .rounded))
            .bold()
            .padding(8)
            .foregroundColor(.onPrimary)
    }
    
    func homePageOption() -> some View {
        self
            .font(.system(size: 17, design: .rounded))
            .foregroundColor(.onSurface)
            .padding(.trailing, 15)
            .padding(.leading, 15)
    }
    
    func dayOfWeek() -> some View {
        self.frame(maxWidth: .infinity)
            .padding(.top, 1)
            .lineLimit(1)
    }
    
    func mainHeaderBoldPrimary() -> some View {
        self.font(.system(size: 26, design: .rounded))
            .bold()
            .padding(.top, 20)
            .foregroundColor(.primary)
    }
    
    func subHeaderBold() -> some View {
        self.font(.system(size: 22, design: .rounded))
            .foregroundColor(.onBackground)
            .bold()
            .padding([.leading, .trailing], 20)
    }
    
    func bottomBarItem(selectedTab: TabbarTabType, thisTab: TabbarTabType) -> some View {
        self.font(.system(size: 10, design: .rounded))
            .foregroundColor(selectedTab == thisTab ? .primary : .onBackground)
    }
    
    func info() -> some View {
        self.font(.system(size: 20, design: .rounded))
            .fontWeight(.semibold)
            .foregroundColor(.onBackground)
            .padding(.bottom, 25)
            .padding([.leading, .trailing], 15)
            .multilineTextAlignment(.center)
    }
    
    func programmeTitle() -> some View {
        self.font(.system(size: 18, weight: .semibold, design: .rounded))
            .multilineTextAlignment(.leading)
            .padding(.bottom, 10)
    }
    
    func programmeSubTitle() -> some View {
        self.font(.system(size: 14, design: .rounded))
            .multilineTextAlignment(.leading)
    }
    
    func searchResultsField() -> some View {
        self.font(.system(size: 18, weight: .semibold, design: .rounded))
            .foregroundColor(.onBackground)
            .padding([.leading, .top], 20)
            .padding(.bottom, 10)
    }
    
    func backButton() -> some View {
        self.font(.system(size: 18, weight: .semibold, design: .rounded))
    }
    
    func timeSpanCard() -> some View {
        self.font(.system(size: 16, design: .rounded))
            .bold()
            .foregroundColor(.onSurface)
    }
    
    func titleCard() -> some View {
        self.font(.system(size: 24, design: .rounded))
            .foregroundColor(.onSurface)
            .padding(.leading, 25)
            .padding(.trailing, 25)
            .padding(.bottom, 2.5)
    }
    
    func courseNameCard() -> some View {
        self.font(.system(size: 18, design: .rounded))
            .foregroundColor(.onSurface)
            .padding(.leading, 25)
            .padding(.bottom, 10)
    }
    
    func locationCard() -> some View {
        self.font(.system(size: 18, design: .rounded))
            .bold()
            .foregroundColor(.onSurface)
    }
    
    func dayHeader() -> some View {
        self.font(.system(size: 24, design: .rounded))
            .padding(.trailing, 10)
    }

    func appVersionDrawer() -> some View {
        self.padding(.bottom, 30)
            .font(.system(size: 12, design: .rounded))
            .foregroundColor(.onSurface)
    }
    
    func popupToast() -> some View {
        self.font(.system(size: 16, design: .rounded))
            .padding(.leading, 15)
            .padding(.trailing, 15)
            .foregroundColor(.white)
            .frame(minWidth: 0, maxWidth: .infinity, minHeight: 45, alignment: .leading)
            .background(.primary).opacity(0.75)
            .cornerRadius(10)
            .padding(.bottom, 165)
            .padding(.leading, 15)
            .padding(.trailing, 15)
    }
}
