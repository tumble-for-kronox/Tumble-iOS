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
            FeatureCard(title: "Saving schedules", image: "bookmark.fill")
            
            FeatureCard(title: "Signing up for events", image: "graduationcap.fill")
            
            FeatureCard(title: "Booking resources", image: "studentdesk")
            
            FeatureCard(title: "Setting notifications", image: "bell.badge.fill")
            
            FeatureCard(title: "Customizing course colors", image: "paintbrush.pointed.fill")
            
        }
        .padding(.bottom, 30)
    }
}

struct AppFeaturesListView_Previews: PreviewProvider {
    static var previews: some View {
        AppFeaturesList()
    }
}
