//
//  AppFeaturesListView.swift
//  tumble-ios
//
//  Created by Adis Veletanlic on 2023-01-28.
//

import SwiftUI

struct AppFeaturesList: View {
    var body: some View {
        ScrollView {
            FeatureCard(title: "Saving schedules", image: "list.bullet.clipboard.fill")
            
            FeatureCard(title: "Signing up for exams", image: "graduationcap.fill")
            
            FeatureCard(title: "Booking rooms", image: "studentdesk")
            
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
