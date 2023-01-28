//
//  TabBarView.swift
//  tumble-ios
//
//  Created by Adis Veletanlic on 11/16/22.
//

import SwiftUI

typealias OnChangeTab = (TabType) -> Void

struct BottomBarView: View {
    @EnvironmentObject var parentViewModel: MainAppView.MainAppViewModel
    var onChangeTab: OnChangeTab
    private var fillImage: String {
        parentViewModel.selectedTab.rawValue + ".fill"
    }
    var body: some View {
        Spacer()
        BottomBarItem(selectedTab: parentViewModel.selectedTab, thisTab: TabType.home, fillImage: TabType.home.rawValue + ".fill", skeletonImage: TabType.home.rawValue, onChangeTab: onChangeTab, animateTransition: parentViewModel.animateTransition)
        Spacer()
        BottomBarItem(selectedTab: parentViewModel.selectedTab, thisTab: TabType.schedule, fillImage: TabType.schedule.rawValue + ".fill", skeletonImage: TabType.schedule.rawValue, onChangeTab: onChangeTab, animateTransition: parentViewModel.animateTransition)
        Spacer()
        BottomBarItem(selectedTab: parentViewModel.selectedTab, thisTab: TabType.account, fillImage: TabType.account.rawValue + ".fill", skeletonImage: TabType.account.rawValue, onChangeTab: onChangeTab, animateTransition: parentViewModel.animateTransition)
        Spacer()
    }
}
