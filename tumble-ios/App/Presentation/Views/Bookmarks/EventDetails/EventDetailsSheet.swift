//
//  EventDetailsView.swift
//  tumble-ios
//
//  Created by Adis Veletanlic on 2023-01-31.
//

import SwiftUI

struct EventDetailsSheet: View {
    
    @ObservedObject var viewModel: EventDetailsSheetViewModel
    
    let createToast: (ToastStyle, String, String) -> Void
    
    var body: some View {
        ScrollView {
            VStack (spacing: 0) {
                EventDetailsCard(createToast: createToast, event: viewModel.event, color: viewModel.color!)
                    .environmentObject(viewModel)
                EventDetailsBody(event: viewModel.event)
                Spacer()
            }
        }
    }
}
