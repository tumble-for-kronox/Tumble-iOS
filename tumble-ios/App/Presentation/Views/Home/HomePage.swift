//
//  HomePageView.swift
//  tumble-ios
//
//  Created by Adis Veletanlic on 11/20/22.
//

import SwiftUI

struct HomePage: View {
    
    @ObservedObject var viewModel: HomePageViewModel
    
    @Binding var domain: String?
    @Binding var canvasUrl: String?
    @Binding var kronoxUrl: String?
    @Binding var selectedAppTab: TabbarTabType
    @Binding var selectedLocalTab: TabbarTabType
    
    let backgroundColor: Color = .primary.opacity(0.75)
    let iconColor: Color = .primary.opacity(0.95)
    
    var body: some View {
        VStack (alignment: .leading, spacing: 0) {
            VStack (alignment: .leading, spacing: 0) {
                if let userName = viewModel.userController.user?.name {
                    Text("Good \(getTimeOfDay()), \(userName.components(separatedBy: " ").first!)!")
                        .font(.system(size: 30, design: .rounded))
                        .fontWeight(.semibold)
                        .padding(.bottom, 10)
                } else {
                    Text("Good \(getTimeOfDay())!")
                        .font(.system(size: 30, design: .rounded))
                        .fontWeight(.semibold)
                        .padding(.bottom, 10)
                }
                
                Text("Where do you want to get started?")
                    .font(.system(size: 25, design: .rounded))
                    .padding(.trailing, 30)
                
                HStack (spacing: 10) {
                    ExternalLinkPill(title: domain?.uppercased() ?? "", image: "link", url: viewModel.makeUniversityUrl())
                    ExternalLinkPill(title: "Canvas", image: "link", url: viewModel.makeCanvasUrl())
                    ExternalLinkPill(title: "Ladok", image: "link", url: URL(string: ladokUrl))
                }
                .padding(.top, 25)

            }
            
            // Schedules, booked rooms, registered exams
            VStack (alignment: .leading, spacing: 0) {
                HomePageOption(titleText: "Schedules", bodyText: "Got a class coming up?", image: "list.bullet.clipboard", onTap: {
                    selectedAppTab = .bookmarks
                    withAnimation(.spring()) {
                        selectedLocalTab = .bookmarks
                    }
                })
                HomePageOption(titleText: "Book a room", bodyText: "Need to study?", image: "books.vertical", onTap: {
                    selectedAppTab = .account
                    withAnimation(.spring()) {
                        selectedLocalTab = .account
                    }
                })
                HomePageOption(titleText: "Register for exams", bodyText: "You've got this!", image: "newspaper", onTap: {
                    selectedAppTab = .account
                    withAnimation(.spring()) {
                        selectedLocalTab = .account
                    }
                })
            }
            .padding(.top, 40)
        }
        .padding(.top, 20)
        .padding(.horizontal, 16)
    }
}
