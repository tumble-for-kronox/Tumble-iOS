//
//  TabBarButton.swift
//  tumble-ios
//
//  Created by Adis Veletanlic on 2023-03-21.
//

import SwiftUI

struct TabBarButton: View {
    var animation: Namespace.ID
    let appTab: TabbarTabType
   
    @Binding var selectedAppTab: TabbarTabType
   
    var body: some View {
        VStack(spacing: 0) {
            Image(systemName: isSelected() ? appTab.rawValue + ".fill" : appTab.rawValue)
                .tabBarIcon(isSelected: isSelected())
            if isSelected() {
                RoundedRectangle(cornerSize: CGSize(width: 16, height: 8))
                    .fill(Color.primary)
                    .matchedGeometryEffect(id: "BOTTOMTAB", in: animation)
                    .frame(width: 20, height: 4)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.top, 10)
        .onTapGesture {
            withAnimation(.spring()) {
                selectedAppTab = appTab
           }
        }
    }
   
    private func isSelected() -> Bool {
       return selectedAppTab.rawValue == appTab.rawValue
    }
}

