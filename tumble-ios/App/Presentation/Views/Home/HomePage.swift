//
//  HomePageView.swift
//  tumble-ios
//
//  Created by Adis Veletanlic on 11/20/22.
//

import SwiftUI

struct HomePage: View {
    
    @ObservedObject var viewModel: HomePage.HomePageViewModel
    @EnvironmentObject var userModel: User
    
    @Binding var domain: String?
    @Binding var canvasUrl: String?
    @Binding var kronoxUrl: String?
    @Binding var selectedTabBar: TabbarTabType
    
    let backgroundColor: Color = .primary.opacity(0.75)
    let iconColor: Color = .primary.opacity(0.95)
    
    var body: some View {
        VStack (alignment: .leading, spacing: 0) {
            VStack (alignment: .leading, spacing: 0) {
                Text(userModel.authStatus == .authorized || userModel.refreshToken != nil ? "Good \(viewModel.getTimeOfDay()), \(userModel.user!.name.components(separatedBy: " ").first!)!" : "Good \(viewModel.getTimeOfDay())!")
                    .font(.system(size: 30, design: .rounded))
                    .fontWeight(.semibold)
                    .padding(.bottom, 10)
                Text("Where do you want to get started?")
                    .font(.system(size: 25, design: .rounded))
                    .padding(.trailing, 30)
                HStack (spacing: 10) {
                    ExternalLinkPill(title: domain?.uppercased() ?? "", image: "link", url: viewModel.makeUniversityUrl())
                    ExternalLinkPill(title: "Canvas", image: "link", url: viewModel.makeCanvasUrl())
                    ExternalLinkPill(title: "Ladok", image: "link", url: URL(string: viewModel.ladokUrl))
                }
                .padding(.top, 25)

            }
            
            // Schedules, booked rooms, registered exams
            VStack (alignment: .leading, spacing: 0) {
                HomePageOption(titleText: "Schedules", bodyText: "Got a class coming up?", image: "list.bullet.clipboard", onTap: {
                    withAnimation(.spring()) {
                        selectedTabBar = .bookmarks
                    }
                })
                HomePageOption(titleText: "Book a room", bodyText: "Need to study?", image: "books.vertical", onTap: {
                    
                })
                HomePageOption(titleText: "Register for exams", bodyText: "You've got this!", image: "newspaper", onTap: {
                    
                })
            }
            .padding(.top, 40)
        }
        .padding(.top, 20)
        .padding(.horizontal, 16)
    }
}
