//
//  BottomBarView.swift
//  tumble-ios
//
//  Created by Adis Veletanlic on 11/16/22.
//

import Foundation
import SwiftUI


struct BottomBarView: View {
    var body: some View {
        TabView {
                HomeView()
                    .tabItem {
                        Image(systemName: "house")
                        
                }
                Text("List")
                    .tabItem {
                        Image(systemName: "list.star")
                        Text("List")
                }
                Text("Week")
                    .tabItem {
                        Image(systemName: "list.bullet.indent")
                        Text("Week")
                }
                Text("Calendar")
                    .tabItem {
                        Image(systemName: "calendar")
                        Text("Calendar")
                }
                Text("Account")
                    .tabItem {
                        Image(systemName: "person")
                        Text("Account")
                }
            }
    }
}

struct BottomBarView_Previews: PreviewProvider {
    static var previews: some View {
        BottomBarView()
    }
}
