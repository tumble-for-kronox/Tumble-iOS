//
//  HomePageView.swift
//  tumble-ios
//
//  Created by Adis Veletanlic on 11/20/22.
//

import SwiftUI

enum QuickAccessId: String {
    case book = "book"
    case exams = "exams"
    case schedules = "schedules"
}

struct HomePageView: View {
    @StateObject var viewModel: HomePageViewModel = HomePageViewModel()
    let backgroundColor: Color = Color("PrimaryColor").opacity(0.75)
    let iconColor: Color = Color("PrimaryColor").opacity(0.95)
    
    var body: some View {
        ScrollView {
            HomePageQuickAccessSectionView(title: "Quick access", image: "tray.full", quickAccessOptions: [
                QuickAccessOption(id: .book, title: "Booked rooms", image: "studentdesk", onClick: {}, backgroundColor: backgroundColor, iconColor: iconColor),
                QuickAccessOption(id: .exams, title: "Registered exams", image: "text.badge.checkmark", onClick: {}, backgroundColor: backgroundColor, iconColor: iconColor),
                QuickAccessOption(id: .schedules, title: "View a schedule", image: "list.clipboard", onClick: {}, backgroundColor: backgroundColor, iconColor: iconColor)
            ])
            .padding(.top, 30)
                        
            HomePageLinkSectionView(title: "Links", image: "link", links: [
                ExternalLink(id: .university, title: viewModel.getUniversityName(), image: "paperclip", backgroundColor: viewModel.getUniversityColor(), iconColor: viewModel.getUniversityColor(), url: viewModel.getUniversityUrl()),
                ExternalLink(id: .canvas, title: "Canvas", image: "paperclip", backgroundColor: .red, iconColor: .red, url: viewModel.getCanvasUrl()),
                ExternalLink(id: .ladok, title: "Ladok", image: "paperclip", backgroundColor: .green, iconColor: .green, url: "ladok.se"),
                ExternalLink(id: .kronox, title: "Kronox", image: "paperclip", backgroundColor: .blue, iconColor: .blue, url: viewModel.getUniversityKronoxUrl()),
            ])
            .padding(.top, 20)
        }
        .padding([.leading, .trailing], 2.5)
    }
}
