//
//  TabItem.swift
//  Tumble
//
//  Created by Adis Veletanlic on 5/5/23.
//

import SwiftUI

struct TabItem: View {
    
    let appTab: TabbarTabType
    @Binding var selectedAppTab: TabbarTabType
    
    var body: some View {
        Image(systemName: imageName())
            .resizable()
            .aspectRatio(contentMode: .fit)
            .frame(width: 30, height: 30)
            .background(Color.red)
            .scaleEffect(isSelected() ? 1.5 : 1.0) // Enlarging by 17% when selected
            .padding(.top, 15)
            .animation(.bouncy, value: isSelected())
    }
    
    func isSelected() -> Bool {
        return appTab == selectedAppTab
    }
    
    func imageName() -> String {
        if isSelected() {
            if appTab != .search {
                return appTab.rawValue + ".fill"
            }
        }
        return appTab.rawValue
    }
}
