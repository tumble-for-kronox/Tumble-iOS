//
//  DrawerContent.swift
//  tumble-ios
//
//  Created by Adis Veletanlic on 11/16/22.
//

import SwiftUI

struct DrawerItem: Identifiable {
    var id: UUID = UUID()
    let text: String
}

struct DrawerContent: View {
    var body: some View {
        ZStack {
            Color("BackgroundColor")
            VStack (alignment: .leading) {
                DrawerRow(title: "School", image: "arrow.left.arrow.right")
                DrawerRow(title: "Theme", image: "apps.iphone")
                DrawerRow(title: "Language", image: "textformat.abc")
                DrawerRow(title: "Schedules", image: "bookmark")
                DrawerRow(title: "Notifications", image: "bell.badge")
                Spacer()
            }
            .padding(.top, 100)
            .padding(.leading, 25)
            .padding(.trailing, 20)
        }
        
    }
}
