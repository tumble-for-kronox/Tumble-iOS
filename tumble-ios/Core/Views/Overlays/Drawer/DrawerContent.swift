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
            Color("PrimaryColor").opacity(0.5)
            VStack (alignment: .leading, spacing: 0) {
                Group {
                    Text("Common")
                        .font(.system(size: 12, weight: .bold, design: .default))
                        .padding(.bottom, 5)
                    
                    DrawerRow(onClick: {
                        showSheet(0)
                    }, title: "School", image: "arrow.left.arrow.right")
                    DrawerRow(onClick: {
                        showSheet(1)
                        
                        
                    }, title: "Theme", image: "apps.iphone")
                    DrawerRow(onClick: {
                        showSheet(2)
                    }, title: "Language", image: "textformat.abc")
                    Divider()
                        .padding(.bottom, 15)
                }
                Group {
                    Text("Schedule")
                        .font(.system(size: 12, weight: .bold, design: .default))
                        .padding(.bottom, 5)
                        .font(Font.headline.weight(.bold))
                    DrawerRow(onClick: {
                        showSheet(3)
                    }, title: "Schedules", image: "bookmark")
                    Divider()
                        .padding(.bottom, 15)
                }
                
                Group {
                    Text("Notifications")
                        .font(.system(size: 12, weight: .bold, design: .default))
                        .padding(.bottom, 5)
                        .font(Font.headline.weight(.bold))
                    DrawerRow(onClick: {
                        showSheet(4)
                    }, title: "Notifications", image: "bell.badge")
                    Divider()
                        .padding(.bottom, 15)
                }
                Spacer()
            }
            .padding(.top, 100)
            .padding(.leading, 15)
            .padding(.trailing, 15)
            
        }
    }
}
