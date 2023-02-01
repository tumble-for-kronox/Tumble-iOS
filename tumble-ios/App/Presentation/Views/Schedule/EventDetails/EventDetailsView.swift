//
//  EventDetailsView.swift
//  tumble-ios
//
//  Created by Adis Veletanlic on 2023-01-31.
//

import SwiftUI

struct EventDetailsView: View {
    
    @ObservedObject var viewModel: EventDetailsViewModel
    
    var body: some View {
        ScrollView {
            VStack (spacing: 0) {
                EventDetailsCardView(event: viewModel.event!, color: viewModel.color!)
                EventDetailsBodyView(event: viewModel.event!)
                Spacer()
            }
        }
    }
}
