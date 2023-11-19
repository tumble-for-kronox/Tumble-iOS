//
//  HomeView.swift
//  Tumble
//
//  Created by Adis Veletanlic on 11/20/22.
//

import SwiftUI
import MijickPopupView

/// All navigation occurs from this view
struct AppParent: View {
    @ObservedObject var viewModel: ParentViewModel
    @ObservedObject var appController: AppController = .shared
    
    private let homeView: AnyView
    private let bookmarkView: AnyView
    private let accountView: AnyView
    
    private let navigationBarAppearance = UINavigationBar.appearance()
    
    init(viewModel: ParentViewModel) {
        navigationBarAppearance.titleTextAttributes = [.font: navigationBarFont()]
        navigationBarAppearance.titleTextAttributes = [.foregroundColor: UIColor(named: "OnSurface")!]
        self.viewModel = viewModel
        self.homeView = Home(
            viewModel: viewModel.homeViewModel,
            parentViewModel: viewModel).eraseToAnyView()
        self.bookmarkView = Bookmarks(
            viewModel: viewModel.bookmarksViewModel,
            parentViewModel: viewModel).eraseToAnyView()
        self.accountView = Account(viewModel: viewModel.accountPageViewModel).eraseToAnyView()
    }
    
    
    var body: some View {
        VStack (spacing: 0) {
            ZStack {
                homeView
                    .opacity(appController.selectedAppTab == .home ? 1 : 0)
                bookmarkView
                    .opacity(appController.selectedAppTab == .bookmarks ? 1 : 0)
                accountView
                    .opacity(appController.selectedAppTab == .account ? 1 : 0)
            }
            CustomTabBar(selectedTab: $appController.selectedAppTab)
        }
        .ignoresSafeArea(.keyboard)
        .fullScreenCover(isPresented: $viewModel.userNotOnBoarded, content: {
            OnBoarding(finishOnBoarding: viewModel.finishOnboarding)
        })
        .navigationViewStyle(StackNavigationViewStyle())
    }
}

struct CustomTabBar: View {
    @Binding var selectedTab: TabbarTabType

    var body: some View {
        VStack(spacing: 0) {
            Divider()
            HStack {
                ForEach(TabbarTabType.allValues, id: \.self) { tab in
                    CustomTabButton(tab: tab, selectedTab: $selectedTab)
                        .frame(maxWidth: .infinity)
                }
            }
            .frame(height: 85)
            .padding(.horizontal)
        }
        .padding(0)
        .background(Color("BackgroundColor"))
    }
}

struct CustomTabButton: View {
    let tab: TabbarTabType
    @Binding var selectedTab: TabbarTabType
    @State private var isAnimating: Bool = false
    
    var body: some View {
        Button(action: onClick, label: {
            Image(systemName: imageName)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 27, height: 27)
                .scaleEffect(isAnimating ? 1.2 : 1.0)
                .foregroundColor(isSelected() ? .primary : .primary.opacity(0.5))
        })
        .frame(height: 60, alignment: .top)
        .padding(.top, 5)
        .animation(.easeInOut(duration: 0.2), value: isAnimating)
    }
    
    func onClick() {
        if selectedTab != tab {
            selectedTab = tab
            isAnimating = true
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                isAnimating = false
            }
            HapticsController.triggerHapticLight()
        }
    }
    
    func isSelected() -> Bool {
        return tab == selectedTab
    }
    
    var imageName: String {
        if isSelected() {
            return tab.rawValue + ".fill"
        }
        return tab.rawValue
    }
}
