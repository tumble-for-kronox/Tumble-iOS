//
//  AppFeaturesListView.swift
//  tumble-ios
//
//  Created by Adis Veletanlic on 2023-01-28.
//

import SwiftUI

struct AppFeaturesList: View {
    var body: some View {
        ScrollView (showsIndicators: false) {
            FeatureCard(
                title: NSLocalizedString("Saving schedules", comment: ""),
                image: "bookmark.fill")
            
            FeatureCard(
                title: NSLocalizedString("Signing up for events", comment: ""),
                image: "graduationcap.fill")
            
            FeatureCard(
                title: NSLocalizedString("Booking resources", comment: ""),
                image: "studentdesk")
            
            FeatureCard(
                title: NSLocalizedString("Setting notifications", comment: ""),
                image: "bell.badge.fill")
            
            FeatureCard(
                title: NSLocalizedString("Customizing course colors", comment: ""),
                image: "paintbrush.pointed.fill")
            
        }
        .padding(.bottom, 30)
    }
}

struct AppFeaturesListView_Previews: PreviewProvider {
    static var previews: some View {
        AppFeaturesList()
    }
}
