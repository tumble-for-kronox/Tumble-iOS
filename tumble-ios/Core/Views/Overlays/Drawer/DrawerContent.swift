//
//  DrawerContent.swift
//  tumble-ios
//
//  Created by Adis Veletanlic on 11/16/22.
//

import SwiftUI

struct DrawerContent: View {
    @StateObject private var viewModel = DrawerViewModel()
    let showSheet: (Int) -> Void
    var body: some View {
        ZStack {
            Color("PrimaryColor").opacity(0.75)
            VStack (alignment: .center, spacing: 0) {
                Group {
                    DrawerItem(onClick: {
                        showSheet(0)
                    }, title: "Language", image: "textformat.abc")
                    
                }
                Group {
                    DrawerItem(onClick: {
                        showSheet(1)
                    }, title: "Notifications", image: "bell.badge")
                    DrawerItem(onClick: {
                        showSheet(2)
                    }, title: "Schedules", image: "bookmark")
                    DrawerItem(onClick: {
                        showSheet(3)
                    }, title: "School", image: "arrow.left.arrow.right")
                    
                    
                }
                Group {
                    DrawerItem(onClick: {
                        showSheet(4)
                    }, title: "Theme", image: "apps.iphone")
                    DrawerItem(onClick: {
                        showSheet(5)
                    }, title: "Support", image: "questionmark.circle")
                    
                }
                Spacer()
                Text("Tumble for Kronox V.3.0.0")
                    .padding(.bottom, 30)
                    .font(.caption)
                    .foregroundColor(.white)
            }
            .padding(.top, 90)
            .padding(.leading, 15)
            .padding(.trailing, 15)
            
        }
    }
}
