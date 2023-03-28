//
//  HomeView.swift
//  tumble-ios
//
//  Created by Adis Veletanlic on 11/20/22.
//


import SwiftUI

// All navigation occurs from this view
struct AppParent: View {
    
    @EnvironmentObject var appController: AppController
    @ObservedObject var viewModel: ParentViewModel
        
    private let navigationBarAppearance = UINavigationBar.appearance()
    private let tabBarAppearance = UITabBar.appearance()
    
    init(viewModel: ParentViewModel) {
        navigationBarAppearance.titleTextAttributes = [.font: navigationBarFont()]
        navigationBarAppearance.titleTextAttributes = [.foregroundColor: UIColor(named: "OnSurface")!]
        tabBarAppearance.backgroundColor = UIColor(named: "BackgroundColor")
        tabBarAppearance.tintColor = UIColor(named: "PrimaryColor")
        self.viewModel = viewModel
    }
    
    var body: some View {
        ZStack {
            Color.surface
                .ignoresSafeArea()
            
            GeometryReader { geometry in
                SidebarMenu(
                    viewModel: viewModel.sidebarViewModel,
                    showSideBar: $appController.showSideBar,
                    selectedBottomTab: $appController.selectedAppTab,
                    createToast: createToast,
                    removeBookmark: removeBookmark,
                    updateBookmarks: updateBookmarks,
                    onChangeSchool: onChangeSchool)
                    .padding(.bottom, geometry.safeAreaInsets.bottom) // apply safe area insets manually
            }
            .ignoresSafeArea(.keyboard)
            
            NavigationView {
                VStack {
                    // Main home page view switcher
                    switch appController.selectedAppTab {
                    case .home:
                        HomePage(
                            viewModel: viewModel.homeViewModel,
                            parentViewModel: viewModel,
                            domain: $viewModel.domain,
                            canvasUrl: $viewModel.canvasUrl,
                            kronoxUrl: $viewModel.kronoxUrl,
                            selectedAppTab: $appController.selectedAppTab
                        )
                    case .bookmarks:
                        BookmarkPage(
                            viewModel: viewModel.bookmarksViewModel,
                            parentViewModel: viewModel,
                            appController: appController
                        )
                    case .account:
                        AccountPage(
                            viewModel: viewModel.accountPageViewModel,
                            createToast: createToast
                        )
                    }
                    TabBar(selectedAppTab: $appController.selectedAppTab)
                }
                .ignoresSafeArea(.keyboard)
                .navigationTitle(appController.selectedAppTab.displayName)
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .navigationBarLeading, content: {
                        NavigationbarSidebar(
                            showSideBar: $appController.showSideBar,
                            handleClose: handleSideBarAction)
                    })
                    ToolbarItem(placement: .navigationBarTrailing, content: {
                        NavigationbarSearch(
                            viewModel: viewModel.searchViewModel,
                            backButtonTitle: appController.selectedAppTab.displayName,
                            checkForNewSchedules: updateBookmarks,
                            universityImage: $viewModel.universityImage)
                    })
                }
                
            }
            .overlay(
                Group {
                    if appController.showSideBar {
                        Color.white.opacity(0.001)
                            .onTapGesture {
                                withAnimation {
                                    handleSideBarAction(
                                        shouldShowSideBar: false
                                    )
                                }
                            }
                    }
                }
            )
            .offset(x: appController.showSideBar ? getRect().width - 120 : 0)
            .toastView(toast: $appController.toast)
            .ignoresSafeArea(.keyboard)
            .navigationViewStyle(StackNavigationViewStyle())
        }
        .zIndex(1)
        .ignoresSafeArea(.keyboard)
    }
    
    fileprivate func handleSideBarAction(shouldShowSideBar: Bool) -> Void {
        appController.showSideBar = shouldShowSideBar
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
        DispatchQueue.main.async {
            appController.toast = Toast(type: type, title: title, message: message)
        }
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

