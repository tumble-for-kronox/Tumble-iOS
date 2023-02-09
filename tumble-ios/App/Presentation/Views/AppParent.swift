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
    
    @ObservedObject var viewModel: ParentViewModel
    
    @State private var toast: Toast? = nil
    @State var selectedSideBarTab: SidebarTabType = .none
    @State var eventSheet: EventSheetModel? = nil
    @State var sideBarSheet: SideBarSheetModel? = nil
    @State var selectedBottomTab: TabbarTabType = .home
    @State var showSideBar: Bool = false
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
            
            SidebarMenu(viewModel: viewModel.sidebarViewModel, selectedSideBarTab: $selectedSideBarTab, selectedBottomTab: $selectedBottomTab, sideBarSheet: $sideBarSheet, removeBookmark: removeBookmark, updateBookmarks: updateBookmarks, onChangeSchool: onChangeSchool)
            
            ZStack {
                FadedPageUnderlay(backgroundOpacity: 0.6, offset: -25, verticalPadding: 30, showSideBar: $showSideBar)
                FadedPageUnderlay(backgroundOpacity: 0.4, offset: -50, verticalPadding: 60, showSideBar: $showSideBar)
                NavigationView {
                    VStack (alignment: .leading) {
                        // Main home page view switcher
                        switch selectedBottomTab {
                        case .home:
                            HomePage(viewModel: viewModel.homeViewModel, domain: $viewModel.domain, canvasUrl: $viewModel.canvasUrl, kronoxUrl: $viewModel.kronoxUrl)
                        case .bookmarks:
                            BookmarkPage(viewModel: viewModel.bookmarksViewModel, onTapCard: onOpenEventDetailsSheet,  createToast: createToast, eventSheet: $eventSheet)
                        case .account:
                            AccountPage(viewModel: viewModel.accountPageViewModel)
                        }
                        Spacer()
                        TabBar(selectedBottomTab: $selectedBottomTab)
                    }
                    .navigationTitle(selectedBottomTab.displayName)
                    .navigationBarTitleDisplayMode(.inline)
                    .toolbar {
                        ToolbarItem(placement: .navigationBarLeading, content: {
                            NavigationbarSidebar(showSideBar: $showSideBar, selectedSideBarTab: $selectedSideBarTab, handleClose: handleSideBarAction)
                        })
                        ToolbarItem(placement: .navigationBarTrailing, content: {
                            NavigationbarSearch(viewModel: viewModel.searchViewModel, backButtonTitle: selectedBottomTab.displayName, checkForNewSchedules: updateBookmarks, universityImage: $viewModel.universityImage)
                        })
                    }.background(Color.background)
                }
                .blur(radius: showSideBar ? 50 : 0)
                .overlay(
                    // If the sidebar is shown, blur the navigation view
                    // and make the whole navigation page clickable so the sidebar
                    // closes if it is tapped
                    Group {
                        if showSideBar {
                            Color.white.opacity(0.1)
                                .onTapGesture {
                                    withAnimation {
                                        handleSideBarAction(shouldShowSideBar: false, newSideBarTab: .none)
                                    }
                                }
                        }
                    }
                )
                .cornerRadius(showSideBar ? 15 : 0)
            }
            .scaleEffect(showSideBar ? 0.84 : 1)
            .offset(x: showSideBar ? getRect().width - 120 : 0)
            .toastView(toast: $toast)
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
                showSideBar = true
            }
            default: break
        }
    }
    
    fileprivate func handleSideBarAction(shouldShowSideBar: Bool, newSideBarTab: SidebarTabType) -> Void {
        showSideBar = shouldShowSideBar
        selectedSideBarTab = newSideBarTab
    }
    
    fileprivate func onChangeSchool(school: School) -> Void {
        viewModel.changeSchool(school: school, closure: { success in
            if success {
                toast = Toast(type: .success, title: "New school", message: "Set \(school.name) to default")
                viewModel.updateLocalsAndChildViews()
            } else {
                toast = Toast(type: .info, title: "School already selected", message: "You already have '\(school.name)' as your default school")
            }
        })
    }
    
    fileprivate func createToast(type: ToastStyle, title: String, message: String) -> Void {
        toast = Toast(type: type, title: title, message: message)
    }
    
    fileprivate func updateBookmarks() -> Void {
        viewModel.updateSchedulesChildView()
    }
    
    fileprivate func onOpenEventDetailsSheet(event: Response.Event, color: Color) -> Void {
        self.eventSheet = EventSheetModel(event: event, color: color)
    }
    
    fileprivate func removeBookmark(id: String) -> Void {
        viewModel.removeSchedule(id: id) { success in
            if success {
                viewModel.updateSchedulesChildView()
                toast = Toast(type: .success, title: "Removed schedule", message: "Successfully removed the schedule '\(id)' from your bookmarks")
            } else {
                toast = Toast(type: .error, title: "Could not remove schedule", message: "The schedule '\(id)' could not be removed from your bookmarks")
            }
        }
    }
}

