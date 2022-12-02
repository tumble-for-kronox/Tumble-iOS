//
//  TabBarView.swift
//  tumble-ios
//
//  Created by Adis Veletanlic on 11/16/22.
//

import SwiftUI

struct TabBarView: View {
    @EnvironmentObject var parentViewModel: TabSwitcherView.TabSwitcherViewModel
    private var fillImage: String {
        parentViewModel.selectedTab.rawValue + ".fill"
    }
    var body: some View {
        HStack {
            ForEach(TabType.allValues, id: \.rawValue) { tab in
                Spacer()
                VStack (spacing: 0) {
                    Image(systemName: parentViewModel.selectedTab == tab ? fillImage : tab.rawValue)
                        .scaleEffect(parentViewModel.selectedTab == tab ? 1.10 : 1.0)
                        .foregroundColor(parentViewModel.selectedTab == tab ? Color("PrimaryColor").opacity(0.85) : Color("OnBackground"))
                        .font(.system(size: 17))
                        .onTapGesture {
                            if !(parentViewModel.selectedTab == tab) {
                                parentViewModel.onChangeTab(tab: tab)
                            }
                        }
                        .padding(.bottom, 5)
                    Text(tab.displayName)
                        .font(.system(size: 10))
                        .foregroundColor(parentViewModel.selectedTab == tab ? Color("PrimaryColor") : Color("OnBackground"))
                        
                }
                .animation(Animation.easeIn.speed(5), value: parentViewModel.animateTransition)
                Spacer()
            }
        }
        .frame(width: nil, height: 50)
        .padding(.bottom, 0)
    }
}
