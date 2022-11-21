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
    case canvas = "canvas"
    case ladok = "ladok"
    case kronox = "kronox"
}

struct HomePageView: View {
    @StateObject var viewModel: HomePageViewModel = HomePageViewModel()
    let backgroundColor: Color = Color("PrimaryColor").opacity(0.75)
    let iconColor: Color = Color("PrimaryColor").opacity(0.95)
    var body: some View {
        HomePageQuickAccessSectionView(title: "Quick access", image: "tray.full", quickAccessOptions: [
            QuickAccessOption(id: .book, title: "Booked rooms", image: "studentdesk", onClick: {}, backgroundColor: backgroundColor, iconColor: iconColor),
            QuickAccessOption(id: .exams, title: "Registered exams", image: "text.badge.checkmark", onClick: {}, backgroundColor: backgroundColor, iconColor: iconColor),
            QuickAccessOption(id: .schedules, title: "View a schedule", image: "list.clipboard", onClick: {}, backgroundColor: backgroundColor, iconColor: iconColor)
        ])
        
        HomePageQuickAccessSectionView(title: "Links", image: "paperclip.badge.ellipsis", quickAccessOptions: [
            QuickAccessOption(id: .canvas, title: "Canvas", image: "paperclip", onClick: {}, backgroundColor: Color.red.opacity(0.75), iconColor: Color.red.opacity(0.95)),
            QuickAccessOption(id: .ladok, title: "Ladok", image: "paperclip", onClick: {}, backgroundColor: Color.green.opacity(0.75), iconColor: Color.green.opacity(0.95)),
            QuickAccessOption(id: .kronox, title: "Kronox", image: "paperclip", onClick: {}, backgroundColor: Color.blue.opacity(0.75), iconColor: Color.blue.opacity(0.95))
            ])
    }
}
