//
//  EventDetailsView.swift
//  tumble-ios
//
//  Created by Adis Veletanlic on 2023-01-31.
//

import SwiftUI

struct EventDetailsSheetView: View {
    
    @ObservedObject var viewModel: EventDetailsViewModel
    
    let createToast: (ToastStyle, String, String) -> Void
    
    var body: some View {
        ScrollView {
            VStack (spacing: 0) {
                EventDetailsCardView(createToast: createToast, event: viewModel.event, color: viewModel.color!)
                    .environmentObject(viewModel)
                EventDetailsBodyView(event: viewModel.event)
                Spacer()
            }
        }
    }
}
