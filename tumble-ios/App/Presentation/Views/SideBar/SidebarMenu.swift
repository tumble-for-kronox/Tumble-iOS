//
//  SideBarMenuView.swift
//  tumble-ios
//
//  Created by Adis Veletanlic on 2023-02-01.
//

import SwiftUI

struct SidebarMenu: View {
    
    @ObservedObject var viewModel: SidebarViewModel
    @EnvironmentObject var userModel: User
    
    @Binding var showSideBar: Bool
    @Binding var selectedSideBarTab: SidebarTabType
    @Binding var selectedBottomTab: TabbarTabType
    @Binding var sideBarSheet: SideBarSheetModel?
    @Namespace var animation
    
    let createToast: (ToastStyle, String, String) -> Void
    let removeBookmark: (String) -> Void
    let updateBookmarks: () -> Void
    let onChangeSchool: (School) -> Void
    
    var body: some View {
        
        VStack(alignment: .leading, spacing: 15) {
            VStack (alignment: .leading) {
                viewModel.universityImage?
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 75, height: 75)
                    .cornerRadius(10)
                Button(action: {
                    // Log out action
                }, label: {
                    // Should be replaced based on if user is signed in or not
                    Text(viewModel.universityName ?? "")
                            .font(.system(size: 20, design: .rounded))
                            .fontWeight(.semibold)
                            .multilineTextAlignment(.leading)
                            .foregroundColor(.surface)
                            .padding(.top, 10)
                })
            }
            .padding(.leading, 10)
            .padding(.top, 40)
            .padding(.trailing, 120)
            
            VStack (alignment: .leading, spacing: 0) {
                SidebarMenuButton(sideBarTabType: .bookmarks, title: SidebarTabType.bookmarks.rawValue, image: "bookmark", selectedSideBarTab: $selectedSideBarTab, sideBarSheet: $sideBarSheet, animation: animation)
                SidebarMenuButton(sideBarTabType: .notifications, title: SidebarTabType.notifications.rawValue, image: "bell.badge", selectedSideBarTab: $selectedSideBarTab, sideBarSheet: $sideBarSheet, animation: animation)
                SidebarMenuButton(sideBarTabType: .school, title: SidebarTabType.school.rawValue, image: "arrow.left.arrow.right", selectedSideBarTab: $selectedSideBarTab, sideBarSheet: $sideBarSheet, animation: animation)
                SidebarMenuButton(sideBarTabType: .support, title: SidebarTabType.support.rawValue, image: "questionmark.circle", selectedSideBarTab: $selectedSideBarTab, sideBarSheet: $sideBarSheet, animation: animation)
                SidebarMenuButton(sideBarTabType: .more, title: SidebarTabType.more.rawValue, image: "ellipsis", selectedSideBarTab: $selectedSideBarTab, sideBarSheet: $sideBarSheet, animation: animation)
            }
            .padding(.top, 40)
            .padding(.leading, -16)
            
            Spacer()
            
            VStack (alignment: .leading, spacing: 0) {
                Button(action: onPress, label: {
                    HStack {
                        Text(userModel.authStatus == .authorized || userModel.refreshToken != nil ? "Log out" : "Log in")
                            .fontWeight(.semibold)
                            .font(.system(size: 20, design: .rounded))
                            .foregroundColor(.background)
                        Image(systemName: userModel.user != nil ? "arrow.left.square" : "arrow.right.square")
                            .foregroundColor(.background)
                            .font(.system(size: 20))
                            .frame(width: 32)
                            
                    }
                    .padding(.horizontal, 25)
                    .padding(.bottom, 15)
                })
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
        .padding(.top, 20)
        .padding(8)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .sheet(item: $sideBarSheet) { (sideBarSheet: SideBarSheetModel) in
            SideBarSheet(parentViewModel: viewModel, updateBookmarks: updateBookmarks, removeBookmark: removeBookmark, sideBarTabType: sideBarSheet.sideBarType, onChangeSchool: onChangeSchool, bookmarks: $viewModel.bookmarks)
        }
    }

    func onPress() -> Void {
        if userModel.authStatus == .authorized || userModel.refreshToken != nil {
            userModel.logOut(completion: { success in
                if success {
                    createToast(.success, "Logged out", "You've logged out from your account")
                } else {
                    createToast(.error, "Error", "Something went wrong when logging out from your account")
                }
            })
        } else {
            withAnimation(.spring()) {
                showSideBar = false
                selectedBottomTab = .account
            }
        }
    }
    
}

