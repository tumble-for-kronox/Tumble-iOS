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
        VStack {
            
            HStack {
                ForEach(TabType.allValues, id: \.rawValue) { tab in
                    Spacer()
                    VStack {
                        Image(systemName: parentViewModel.selectedTab == tab ? fillImage : tab.rawValue)
                            .scaleEffect(parentViewModel.selectedTab == tab ? 1.25 : 1.0)
                            .foregroundColor(parentViewModel.selectedTab == tab ? Color("PrimaryColor").opacity(0.85) : .black)
                            .font(.system(size: 20))
                            .onTapGesture {
                                if !(parentViewModel.selectedTab == tab) {
                                    parentViewModel.onChangeTab(tab: tab)
                                }
                            }
                            .padding(.bottom, 5)
                        Text(tab.displayName)
                            .font(.system(size: 10))
                            .foregroundColor(parentViewModel.selectedTab == tab ? Color("PrimaryColor").opacity(0.85) : Color("SecondaryColor").opacity(0.90))
                    }
                    .animation(Animation.easeIn.speed(2), value: parentViewModel.animateTransition)
                    Spacer()
                }
            }
            .frame(width: nil, height: 35)
            .padding(.top, 10)
            .padding(.bottom, 5)
            .padding(.leading, 15)
            .padding(.trailing, 15)
        }
    }
}
