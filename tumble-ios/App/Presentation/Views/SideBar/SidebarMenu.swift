//
//  SideBarMenuView.swift
//  tumble-ios
//
//  Created by Adis Veletanlic on 2023-02-01.
//

import SwiftUI

struct SidebarMenu: View {
    
    @ObservedObject var viewModel: SidebarViewModel
    
    @Binding var showSideBar: Bool
    @State var selectedSideBarTab: SidebarTabType = .none
    @Binding var selectedBottomTab: TabbarTabType
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
                Text(viewModel.universityName ?? "")
                    .font(.system(size: 20))
                    .fontWeight(.semibold)
                    .multilineTextAlignment(.leading)
                    .foregroundColor(.onSurface)
                    .padding(.top, 10)
            }
            .padding(.leading, 10)
            .padding(.top, 40)
            .padding(.trailing, 120)
            
            /// List of sidebar menu options. Each onClick should
            /// direct the user to a separate sheet view.
            VStack (alignment: .leading, spacing: 0) {
                SidebarMenuButton(sideBarTabType: .bookmarks,
                                  title: SidebarTabType.bookmarks.rawValue, image: "bookmark",
                                  parentViewModel: viewModel, selectedSideBarTab: $selectedSideBarTab,
                                  animation: animation)
                SidebarMenuButton(sideBarTabType: .notifications,
                                  title: SidebarTabType.notifications.rawValue, image: "bell.badge",
                                  parentViewModel: viewModel, selectedSideBarTab: $selectedSideBarTab,
                                  animation: animation)
                SidebarMenuButton(sideBarTabType: .school,
                                  title: SidebarTabType.school.rawValue, image: "arrow.left.arrow.right",
                                  parentViewModel: viewModel, selectedSideBarTab: $selectedSideBarTab,
                                  animation: animation)
                SidebarMenuButton(sideBarTabType: .support,
                                  title: SidebarTabType.support.rawValue, image: "questionmark.circle",
                                  parentViewModel: viewModel, selectedSideBarTab: $selectedSideBarTab,
                                  animation: animation)
                SidebarMenuButton(sideBarTabType: .more,
                                  title: SidebarTabType.more.rawValue, image: "ellipsis",
                                  parentViewModel: viewModel, selectedSideBarTab: $selectedSideBarTab,
                                  animation: animation)
            }
            .padding(.top, 40)
            .padding(.leading, -16)
            
            Spacer()
            
            VStack (alignment: .leading, spacing: 0) {
                Button(action: onPress, label: {
                    HStack {
                        Text(viewModel.userController.authStatus == .authorized || viewModel.userController.refreshToken != nil ? "Log out" : "Log in")
                            .fontWeight(.semibold)
                            .font(.system(size: 20))
                            .foregroundColor(.onSurface)
                        Image(systemName: viewModel.userController.user != nil ? "arrow.left.square" : "arrow.right.square")
                            .foregroundColor(.onSurface)
                            .font(.system(size: 20))
                            .frame(width: 32)
                            
                    }
                    .padding(.horizontal, 25)
                    .padding(.bottom, 15)
                })
                .padding(.leading, -16)
                Text("App Version 3.0.0")
                    .font(.system(size: 14))
                    .foregroundColor(.onSurface)
                    .fontWeight(.semibold)
                    .opacity(0.7)
                    .padding(.bottom, 55)
                    .padding(.leading, 8)
            }
            
        }
        .padding(.top, 20)
        .padding(8)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .sheet(isPresented: $viewModel.presentSidebarSheet, onDismiss: {
            viewModel.presentSidebarSheet = false
        }, content: {
            if let sidebarSheetType = viewModel.sidebarSheetType {
                SideBarSheet(
                    parentViewModel: viewModel,
                    updateBookmarks: updateBookmarks,
                    removeBookmark: removeBookmark,
                    sideBarTabType: sidebarSheetType,
                    onChangeSchool: onChangeSchool,
                    bookmarks: $viewModel.bookmarks
                )
            }
        })
    }

    func onPress() -> Void {
        if viewModel.userController.authStatus == .authorized || viewModel.userController.refreshToken != nil {
            viewModel.userController.logOut(completion: { success in
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

