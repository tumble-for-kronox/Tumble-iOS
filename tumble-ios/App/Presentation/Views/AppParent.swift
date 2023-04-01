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
    
    init(viewModel: ParentViewModel) {
        navigationBarAppearance.titleTextAttributes = [.font: navigationBarFont()]
        navigationBarAppearance.titleTextAttributes = [.foregroundColor: UIColor(named: "OnSurface")!]
        self.viewModel = viewModel
    }
    
    var body: some View {
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
                ToolbarItem(placement: .navigationBarTrailing, content: {
                    NavigationbarSearch(
                        viewModel: viewModel.searchViewModel,
                        checkForNewSchedules: updateBookmarks,
                        universityImage: $viewModel.universityImage)
                })
                ToolbarItem(placement: .navigationBarTrailing, content: {
                    NavigationbarSettings(
                        viewModel: viewModel.settingsViewModel,
                        onChangeSchool: onChangeSchool,
                        updateBookmarks: updateBookmarks,
                        removeSchedule: removeSchedule)
                })
            }
        }
        .tint(.primary)
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
        .zIndex(1)
        .ignoresSafeArea(.keyboard)
    }
    
    fileprivate func handleSideBarAction(shouldShowSideBar: Bool) -> Void {
        appController.showSideBar = shouldShowSideBar
    }
    
    fileprivate func onChangeSchool(school: School) -> Void {
        viewModel.changeSchool(school: school, closure: { success in
            if success {
                appController.toast = Toast(
                    type: .success,
                    title: NSLocalizedString("New school", comment: ""),
                    message: String(format: NSLocalizedString("Set %@ to default", comment: ""), school.name))
                viewModel.updateLocalsAndChildViews()
                viewModel.logOutUser()
            } else {
                appController.toast = Toast(
                    type: .info,
                    title: NSLocalizedString("School already selected", comment: ""),
                    message: String(format: NSLocalizedString("You already have '%@' as your default school", comment: ""), school.name))
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
    
    fileprivate func removeSchedule(where id: String) -> Void {
        viewModel.removeSchedule(id: id) { success in
            if success {
                viewModel.updateSchedulesChildView()
                appController.toast = Toast(
                    type: .success,
                    title: NSLocalizedString("Removed schedule", comment: ""),
                    message: String(format: NSLocalizedString("Successfully removed the schedule '%@' from your bookmarks", comment: ""), id)
                )
            } else {
                appController.toast = Toast(
                    type: .error,
                    title: NSLocalizedString("Could not remove schedule", comment: ""),
                    message: String(format: NSLocalizedString("The schedule '%@' could not be removed from your bookmarks", comment: ""), id)
                )
            }
        }
    }

}

