//
//  TabBar.swift
//  tumble-ios
//
//  Created by Adis Veletanlic on 2023-03-21.
//

import SwiftUI

struct TabBar: View {
    @Binding var selectedAppTab: TabbarTabType
        
        var body: some View {
            HStack (spacing: 0) {
                TabBarButton(appTab: .home, selectedAppTab: $selectedAppTab)
                TabBarButton(appTab: .bookmarks, selectedAppTab: $selectedAppTab)
                TabBarButton(appTab: .account, selectedAppTab: $selectedAppTab)
            }
            .frame(maxHeight: 20)
            .padding()
            .background(Color.surface)
        }
}

