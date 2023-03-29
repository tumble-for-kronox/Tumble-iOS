//
//  TabBarButton.swift
//  tumble-ios
//
//  Created by Adis Veletanlic on 2023-03-21.
//

import SwiftUI

struct TabBarButton: View {
    let appTab: TabbarTabType
   
    @Binding var selectedAppTab: TabbarTabType
   
    var body: some View {
        VStack(spacing: 0) {
            Image(systemName: isSelected() ? appTab.rawValue + ".fill" : appTab.rawValue)
                .tabBarIcon(isSelected: isSelected())
            Text(appTab.displayName)
                .font(.system(size: 10, weight: .semibold))
                .foregroundColor(isSelected() ? .primary : .onSurface.opacity(0.5))
                .padding(.top, 5)
        }
        .frame(maxWidth: .infinity)
        .padding(.top, 10)
        .onTapGesture {
            self.selectedAppTab = appTab
        }
    }
   
    private func isSelected() -> Bool {
       return selectedAppTab.rawValue == appTab.rawValue
    }
}

