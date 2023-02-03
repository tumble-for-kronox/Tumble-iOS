//
//  AppFeaturesListView.swift
//  tumble-ios
//
//  Created by Adis Veletanlic on 2023-01-28.
//

import SwiftUI

struct AppFeaturesListView: View {
    var body: some View {
        ScrollView {
            FeatureCardView(title: "Saving schedules", image: "list.bullet.clipboard.fill")
            
            FeatureCardView(title: "Signing up for exams", image: "graduationcap.fill")
            
            FeatureCardView(title: "Booking rooms", image: "studentdesk")
            
            FeatureCardView(title: "Setting notifications", image: "bell.badge.fill")
            
            FeatureCardView(title: "Customizing course colors", image: "paintbrush.pointed.fill")
            
        }
        .padding(.bottom, 30)
    }
}

struct AppFeaturesListView_Previews: PreviewProvider {
    static var previews: some View {
        AppFeaturesListView()
    }
}
