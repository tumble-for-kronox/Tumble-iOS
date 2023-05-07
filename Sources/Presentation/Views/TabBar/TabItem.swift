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
        let uiImage = UIImage(systemName: imageName())?.resizeImage(targetSize: CGSize(width: 25, height: 25))
        VStack {
            Image(uiImage: uiImage!)
            Text(appTab.displayName)
        }
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
