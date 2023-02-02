//
//  SideBarMenuView.swift
//  tumble-ios
//
//  Created by Adis Veletanlic on 2023-02-01.
//

import SwiftUI

struct SideBarMenuView: View {
    
    @Binding var selectedSideBarTab: SideBarTabType
    @Binding var selectedBottomTab: BottomTabType
    @Namespace var animation
    
    let universityImage: Image
    let universityName: String
    
    var body: some View {
        
        VStack(alignment: .leading, spacing: 15) {
            VStack (alignment: .leading) {
                universityImage
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 75, height: 75)
                    .cornerRadius(10)
                Button(action: {
                    // Sign in action
                }, label: {
                    // Should be replaced based on if user is signed in or not
                        Text(universityName)
                            .font(.system(size: 18, design: .rounded))
                            .fontWeight(.semibold)
                            .foregroundColor(.surface)
                            .padding(.top, 10)
                })
            }
            .padding(.leading, 10)
            .padding(.top, 40)
            
            VStack (alignment: .leading, spacing: 0) {
                SideBarButtonView(sideBarTabType: .home, title: "Home", image: "house", selectedSideBarTab: $selectedSideBarTab, selectedBottomTab: $selectedBottomTab, animation: animation)
                SideBarButtonView(sideBarTabType: .schedule, title: "Schedules", image: "bookmark", selectedSideBarTab: $selectedSideBarTab, selectedBottomTab: $selectedBottomTab, animation: animation)
                SideBarButtonView(sideBarTabType: .account, title: "Account", image: "person", selectedSideBarTab: $selectedSideBarTab, selectedBottomTab: $selectedBottomTab, animation: animation)
                SideBarButtonView(sideBarTabType: .settings, title: "Settings", image: "gearshape", selectedSideBarTab: $selectedSideBarTab, selectedBottomTab: $selectedBottomTab, animation: animation)
                SideBarButtonView(sideBarTabType: .theme, title: "Theme", image: "paintbrush", selectedSideBarTab: $selectedSideBarTab, selectedBottomTab: $selectedBottomTab, animation: animation)
                SideBarButtonView(sideBarTabType: .notifications, title: "Notifications", image: "bell.badge", selectedSideBarTab: $selectedSideBarTab, selectedBottomTab: $selectedBottomTab, animation: animation)
                SideBarButtonView(sideBarTabType: .school, title: "Schools", image: "arrow.left.arrow.right", selectedSideBarTab: $selectedSideBarTab, selectedBottomTab: $selectedBottomTab, animation: animation)
                SideBarButtonView(sideBarTabType: .support, title: "Support", image: "questionmark.circle", selectedSideBarTab: $selectedSideBarTab, selectedBottomTab: $selectedBottomTab, animation: animation)
            }
            .padding(.top, 20)
            .padding(.leading, -16)
            
            Spacer()
            
            VStack (alignment: .leading, spacing: 0) {
                SideBarButtonView(sideBarTabType: .logOut, title: "Log out", image: "rectangle.righthalf.inset.fill.arrow.right", selectedSideBarTab: $selectedSideBarTab, selectedBottomTab: $selectedBottomTab, animation: animation)
                    .padding(.leading, -16)
                Text("App Version 3.0.0")
                    .font(.system(size: 14, design: .rounded))
                    .foregroundColor(.surface)
                    .fontWeight(.semibold)
                    .opacity(0.7)
                    .padding(.bottom, 55)
                    .padding(.leading, 8)
            }
            
        }
        .padding(.top, 15)
        .padding(8)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
    }
}

