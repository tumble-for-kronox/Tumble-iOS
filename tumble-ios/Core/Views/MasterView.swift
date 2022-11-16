//
//  HomeView.swift
//  tumble-ios
//
//  Created by Adis Veletanlic on 11/16/22.
//

import Foundation

import SwiftUI


struct MasterView: View {
    @ObservedObject var  masterController: MasterViewController
    var body: some View {
        Group {
            NavigationView {
                TabView {
                    Text("Home")
                            .tabItem {
                                Image(systemName: "house")
                                Text("Home")
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
            .sheet(isPresented: $masterController.showingSheet) {
                SchoolSelectView()
                    .interactiveDismissDisabled()
            .environment(\.colorScheme, .dark)
            }
            
        }
    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        MasterView(masterController: MasterViewController())
    }
}
