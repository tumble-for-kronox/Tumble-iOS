//
//  HomeView.swift
//  tumble-ios
//
//  Created by Adis Veletanlic on 11/20/22.
//

// The sidebar menu used in this project:
// https://kavsoft.dev/swiftui_2.0_animated_navigation_menu

import SwiftUI

struct AppParentModel {
    var toast: Toast? = nil
    var selectedSideBarTab: SidebarTabType = .none
    var sideBarSheet: SideBarSheetModel? = nil
    var showSideBar: Bool = false
}

// All navigation occurs from this view
struct AppParent: View {
    
    @ObservedObject var appDelegateViewStateManager: AppDelegateViewStateManager = AppDelegateViewStateManager.shared
    @ObservedObject var viewModel: ParentViewModel
    
    @State private var appParentModel: AppParentModel = AppParentModel()
    @Namespace var animation
    
    private let sideBarWidth: CGFloat = 110
    
    init(viewModel: ParentViewModel) {
        UINavigationBar.appearance().titleTextAttributes = [.font: navigationBarFont()]
        self.viewModel = viewModel
    }
    
    var body: some View {
        ZStack {
            Color.primary
                .ignoresSafeArea()
            
            SidebarMenu(viewModel: viewModel.sidebarViewModel, selectedSideBarTab: $appParentModel.selectedSideBarTab, selectedBottomTab: $appDelegateViewStateManager.selectedTab, sideBarSheet: $appParentModel.sideBarSheet, removeBookmark: removeBookmark, updateBookmarks: updateBookmarks, onChangeSchool: onChangeSchool)
            
            ZStack {
                FadedPageUnderlay(backgroundOpacity: 0.6, offset: -25, verticalPadding: 30, showSideBar: $appParentModel.showSideBar)
                FadedPageUnderlay(backgroundOpacity: 0.4, offset: -50, verticalPadding: 60, showSideBar: $appParentModel.showSideBar)
                NavigationView {
                    VStack (alignment: .leading) {
                        // Main home page view switcher
                        switch appDelegateViewStateManager.selectedTab {
                        case .home:
                            HomePage(viewModel: viewModel.homeViewModel, domain: $viewModel.domain, canvasUrl: $viewModel.canvasUrl, kronoxUrl: $viewModel.kronoxUrl)
                        case .bookmarks:
                            BookmarkPage(viewModel: viewModel.bookmarksViewModel, eventSheet: $appDelegateViewStateManager.eventSheet, onTapCard: onOpenEventDetailsSheet,  createToast: createToast)
                        case .account:
                            AccountPage(viewModel: viewModel.accountPageViewModel)
                        }
                        Spacer()
                        TabBar(selectedBottomTab: $appDelegateViewStateManager.selectedTab)
                    }
                    .navigationTitle(appDelegateViewStateManager.selectedTab.displayName)
                    .navigationBarTitleDisplayMode(.inline)
                    .toolbar {
                        ToolbarItem(placement: .navigationBarLeading, content: {
                            NavigationbarSidebar(showSideBar: $appParentModel.showSideBar, selectedSideBarTab: $appParentModel.selectedSideBarTab, handleClose: handleSideBarAction)
                        })
                        ToolbarItem(placement: .navigationBarTrailing, content: {
                            NavigationbarSearch(viewModel: viewModel.searchViewModel, backButtonTitle: appDelegateViewStateManager.selectedTab.displayName, checkForNewSchedules: updateBookmarks, universityImage: $viewModel.universityImage)
                        })
                    }.background(Color.background)
                }
                .blur(radius: appParentModel.showSideBar ? 50 : 0)
                .overlay(
                    // If the sidebar is shown, blur the navigation view
                    // and make the whole navigation page clickable so the sidebar
                    // closes if it is tapped
                    Group {
                        if appParentModel.showSideBar {
                            Color.white.opacity(0.1)
                                .onTapGesture {
                                    withAnimation {
                                        handleSideBarAction(shouldShowSideBar: false, newSideBarTab: .none)
                                    }
                                }
                        }
                    }
                )
                .cornerRadius(appParentModel.showSideBar ? 15 : 0)
            }
            .scaleEffect(appParentModel.showSideBar ? 0.84 : 1)
            .offset(x: appParentModel.showSideBar ? getRect().width - 120 : 0)
            .toastView(toast: $appParentModel.toast)
            .ignoresSafeArea()
        }
        .gesture(DragGesture(minimumDistance: 3.0, coordinateSpace: .local)
            .onEnded(handleSwipe)
        )
        .zIndex(1)
        .transition(.asymmetric(insertion: .move(edge: .trailing), removal: .move(edge: .leading)))
    }
    
    
    
    fileprivate func handleSwipe(value: DragGesture.Value) -> Void {
        switch(value.translation.width, value.translation.height) {
            case (...0, -30...30):  withAnimation {
                handleSideBarAction(shouldShowSideBar: false, newSideBarTab: .none)
            }
            case (0..., -30...30):  withAnimation {
                appParentModel.showSideBar = true
            }
            default: break
        }
    }
    
    fileprivate func handleSideBarAction(shouldShowSideBar: Bool, newSideBarTab: SidebarTabType) -> Void {
        appParentModel.showSideBar = shouldShowSideBar
        appParentModel.selectedSideBarTab = newSideBarTab
    }
    
    fileprivate func onChangeSchool(school: School) -> Void {
        viewModel.changeSchool(school: school, closure: { success in
            if success {
                appParentModel.toast = Toast(type: .success, title: "New school", message: "Set \(school.name) to default")
                viewModel.updateLocalsAndChildViews()
            } else {
                appParentModel.toast = Toast(type: .info, title: "School already selected", message: "You already have '\(school.name)' as your default school")
            }
        })
    }
    
    fileprivate func createToast(type: ToastStyle, title: String, message: String) -> Void {
        appParentModel.toast = Toast(type: type, title: title, message: message)
    }
    
    fileprivate func updateBookmarks() -> Void {
        viewModel.updateSchedulesChildView()
    }
    
    fileprivate func onOpenEventDetailsSheet(event: Response.Event, color: Color) -> Void {
        appDelegateViewStateManager.eventSheet = EventDetailsSheetModel(event: event, color: color)
    }
    
    fileprivate func removeBookmark(id: String) -> Void {
        viewModel.removeSchedule(id: id) { success in
            if success {
                viewModel.updateSchedulesChildView()
                appParentModel.toast = Toast(type: .success, title: "Removed schedule", message: "Successfully removed the schedule '\(id)' from your bookmarks")
            } else {
                appParentModel.toast = Toast(type: .error, title: "Could not remove schedule", message: "The schedule '\(id)' could not be removed from your bookmarks")
            }
        }
    }
}

