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
    @ObservedObject var viewModel: HomePageViewModel
    
    @Binding var domain: String?
    @Binding var canvasUrl: String?
    @Binding var kronoxUrl: String?
    
    let backgroundColor: Color = .primary.opacity(0.75)
    let iconColor: Color = .primary.opacity(0.95)
    
    var body: some View {
        VStack (alignment: .leading, spacing: 0) {
            VStack (alignment: .leading, spacing: 0) {
                Text("Good \(viewModel.getTimeOfDay())!")
                    .font(.system(size: 30, design: .rounded))
                    .fontWeight(.semibold)
                    .padding(.bottom, 10)
                Text("Where do you want to get started?")
                    .font(.system(size: 25, design: .rounded))
                    .padding(.trailing, 30)
                HStack {
                    EventDetailsPill(title: domain?.uppercased() ?? "", image: "link")
                    EventDetailsPill(title: "Canvas", image: "link")
                    EventDetailsPill(title: "Ladok", image: "link")
                }
                .padding(.top, 25)

            }
            
            // Schedules, booked rooms, registered exams
            VStack (alignment: .leading, spacing: 0) {
                HomePageEventView(titleText: "Schedules", bodyText: "Got a class coming up?", image: "list.bullet.clipboard")
                HomePageEventView(titleText: "Booked rooms", bodyText: "Need to study?", image: "books.vertical")
                HomePageEventView(titleText: "Registered exams", bodyText: "You've got this!", image: "newspaper")
            }
            .padding(.top, 40)
        }
        .padding(.top, 10)
        .padding(.horizontal, 16)
    }
}
