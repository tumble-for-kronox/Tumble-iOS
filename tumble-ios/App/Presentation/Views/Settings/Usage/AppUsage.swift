//
//  AppUsage.swift
//  tumble-ios
//
//  Created by Adis Veletanlic on 2023-03-31.
//

import SwiftUI

struct AppUsage: View {
    
    @State private var viewedTab: Int = 0
    
    var body: some View {
        TabView (selection: $viewedTab) {
            OnBoardingViewBuilder (
                header: NSLocalizedString("Let's get started", comment: ""),
                subHeader: NSLocalizedString("We'll walk you through how to use Tumble", comment: "")) {
                AppFeaturesList()
            }.tag(0)
            OnBoardingViewBuilder (
                header: NSLocalizedString("Saving schedules", comment: ""),
                subHeader: NSLocalizedString("Here's how to save a schedule", comment: "")) {
                BookmarkInstructions()
            }.tag(1)
            OnBoardingViewBuilder (
                header: NSLocalizedString("Signing up for events", comment: ""),
                subHeader: NSLocalizedString("Here's how to sign up for an event", comment: "")) {
                ExamInstructions()
            }.tag(2)
            OnBoardingViewBuilder (
                header: NSLocalizedString("Booking resources", comment: ""),
                subHeader: NSLocalizedString("Here's how to book a resource", comment: "")) {
                BookingInstructions()
            }.tag(3)
            OnBoardingViewBuilder (
                header: NSLocalizedString("Setting notifications", comment: ""),
                subHeader: NSLocalizedString("Here's how to set notifications", comment: "")) {
                NotificationInstructions()
            }.tag(4)
            OnBoardingViewBuilder (
                header: NSLocalizedString("Customizing course colors", comment: ""),
                subHeader: NSLocalizedString("Here's how to modify course colors", comment: "")) {
                ColorInstructions()
            }.tag(5)
        }
        .background(Color.background)
        .tabViewStyle(.page)
        .indexViewStyle(.page(backgroundDisplayMode: .interactive))
    }
}

struct AppUsage_Previews: PreviewProvider {
    static var previews: some View {
        AppUsage()
    }
}
