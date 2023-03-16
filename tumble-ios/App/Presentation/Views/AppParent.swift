//
//  HomeView.swift
//  tumble-ios
//
//  Created by Adis Veletanlic on 11/20/22.
//

// The sidebar menu used in this project:
// https://kavsoft.dev/swiftui_2.0_animated_navigation_menu

import SwiftUI

// All navigation occurs from this view
struct AppParent: View {
    
    @EnvironmentObject var appController: AppController
    
    @ObservedObject var viewModel: ParentViewModel
    @Namespace var animation
    
    @State private var showModal: Bool = true
    
    private let sideBarWidth: CGFloat = 110
    
    init(viewModel: ParentViewModel) {
        UINavigationBar.appearance().titleTextAttributes = [.font: navigationBarFont()]
        UINavigationBar.appearance().titleTextAttributes = [.foregroundColor: UIColor(named: "OnSurface")!]
        self.viewModel = viewModel
    }
    
    var body: some View {
        ZStack {
            Color.primary
                .ignoresSafeArea()
            
            SidebarMenu(
                viewModel: viewModel.sidebarViewModel,
                showSideBar: $appController.showSideBar,
                selectedSideBarTab: $appController.selectedSideBarTab,
                selectedBottomTab: $appController.selectedTab, sideBarSheet: $appController.sideBarSheet,
                createToast: createToast,
                removeBookmark: removeBookmark,
                updateBookmarks: updateBookmarks,
                onChangeSchool: onChangeSchool)
            
            NavigationView {
                VStack {
                    // Main home page view switcher
                    switch appController.selectedTab {
                    case .home:
                        HomePage(
                            viewModel: viewModel.homeViewModel,
                            domain: $viewModel.domain,
                            canvasUrl: $viewModel.canvasUrl,
                            kronoxUrl: $viewModel.kronoxUrl,
                            selectedTabBar: $appController.selectedTab
                        )
                    case .bookmarks:
                        BookmarkPage(
                            viewModel: viewModel.bookmarksViewModel,
                            appController: appController
                        )
                    case .account:
                        AccountPage(
                            viewModel: viewModel.accountPageViewModel,
                            createToast: createToast
                        )
                    }
                    Spacer()
                    TabBar(selectedBottomTab: $appController.selectedTab)
                }
                .ignoresSafeArea(.keyboard)
                .navigationTitle(appController.selectedTab.displayName)
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .navigationBarLeading, content: {
                        NavigationbarSidebar(
                            showSideBar: $appController.showSideBar,
                            selectedSideBarTab: $appController.selectedSideBarTab,
                            handleClose: handleSideBarAction)
                    })
                    ToolbarItem(placement: .navigationBarTrailing, content: {
                        NavigationbarSearch(
                            viewModel: viewModel.searchViewModel,
                            backButtonTitle: appController.selectedTab.displayName,
                            checkForNewSchedules: updateBookmarks,
                            universityImage: $viewModel.universityImage)
                    })
                }
                .background(Color.background)
            }
            .overlay(
                Group {
                    if appController.showSideBar {
                        Color.white.opacity(0.001)
                            .onTapGesture {
                                withAnimation {
                                    handleSideBarAction(
                                        shouldShowSideBar: false,
                                        newSideBarTab: .none
                                    )
                                }
                            }
                    }
                }
            )
            .offset(x: appController.showSideBar ? getRect().width - 120 : 0)
            .toastView(toast: $appController.toast)
            .ignoresSafeArea()
        }
        .zIndex(1)
    }
    
    fileprivate func handleSideBarAction(shouldShowSideBar: Bool, newSideBarTab: SidebarTabType) -> Void {
        appController.showSideBar = shouldShowSideBar
        appController.selectedSideBarTab = newSideBarTab
    }
    
    fileprivate func onChangeSchool(school: School) -> Void {
        viewModel.changeSchool(school: school, closure: { success in
            if success {
                appController.toast = Toast(type: .success, title: "New school", message: "Set \(school.name) to default")
                viewModel.updateLocalsAndChildViews()
                viewModel.userController.logOut()
            } else {
                appController.toast = Toast(type: .info, title: "School already selected", message: "You already have '\(school.name)' as your default school")
            }
        })
    }
    
    fileprivate func createToast(type: ToastStyle, title: String, message: String) -> Void {
        appController.toast = Toast(type: type, title: title, message: message)
    }
    
    fileprivate func updateBookmarks() -> Void {
        viewModel.updateSchedulesChildView()
    }
    
    fileprivate func removeBookmark(id: String) -> Void {
        viewModel.removeSchedule(id: id) { success in
            if success {
                viewModel.updateSchedulesChildView()
                appController.toast = Toast(
                    type: .success,
                    title: "Removed schedule",
                    message: "Successfully removed the schedule '\(id)' from your bookmarks")
            } else {
                appController.toast = Toast(
                    type: .error,
                    title: "Could not remove schedule",
                    message: "The schedule '\(id)' could not be removed from your bookmarks")
            }
        }
    }
}

