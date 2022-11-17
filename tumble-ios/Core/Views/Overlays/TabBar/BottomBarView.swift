//
//  TabBarView.swift
//  tumble-ios
//
//  Created by Adis Veletanlic on 11/16/22.
//

import SwiftUI

struct BottomBarView: View {
    @EnvironmentObject var viewModel: RootView.RootViewModel
    private var fillImage: String {
        viewModel.selectedTab.rawValue + ".fill"
    }
    var body: some View {
        VStack {
            HStack {
                ForEach(Tab.allValues, id: \.rawValue) { tab in
                    Spacer()
                    VStack {
                        Image(systemName: viewModel.selectedTab == tab ? fillImage : tab.rawValue)
                            .scaleEffect(viewModel.selectedTab == tab ? 1.25 : 1.0)
                            .foregroundColor(viewModel.selectedTab == tab ? Color("PrimaryColor") : .gray)
                            .font(.system(size: 20))
                            .onTapGesture {
                                withAnimation(.easeIn(duration: 0.1)) {
                                    viewModel.selectedTab = tab
                                }
                            }
                            .padding(.bottom, 5)
                        Text(tab.displayName)
                            .font(.system(size: 10))
                            .foregroundColor(viewModel.selectedTab == tab ? Color("PrimaryColor") : .gray)
                    }
                    Spacer()
                }
            }
            .frame(width: nil, height: 50)
            .backgroundStyle(.thinMaterial)
            //.cornerRadius(10)
            .padding(.leading, 10)
            .padding(.trailing, 10)
            .padding(.bottom, 30)
        }
    }
}

struct TabBarView_Previews: PreviewProvider {
    static var previews: some View {
        BottomBarView()
    }
}
