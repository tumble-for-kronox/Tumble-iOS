//
//  EventDetailsView.swift
//  tumble-ios
//
//  Created by Adis Veletanlic on 2023-01-31.
//

import SwiftUI

struct EventDetailsSheet: View {
    
    @ObservedObject var viewModel: EventDetailsSheetViewModel
    @State var presentColorPicker: Bool = false
    
    let updateCourseColors: () -> Void
    
    var body: some View {
        ScrollView (showsIndicators: false) {
            VStack (spacing: 0) {
                EventDetailsCard(
                    parentViewModel: viewModel,
                    openColorPicker: openColorPicker,
                    event: viewModel.event,
                    color: viewModel.color)
                EventDetailsBody(event: viewModel.event)
                Spacer()
            }
        }
        .background(Color.background)
        .background(
            ColorPicker(NSLocalizedString("Select course color", comment: ""), selection: $viewModel.color, supportsOpacity: false)
                .labelsHidden().opacity(0)
                
        )
        .onDisappear(perform: {
            updateCourseColors()
            AppController.shared.eventSheet = nil
        })
    }
    
    
    func openColorPicker() -> Void {
        UIColorWellHelper.helper.execute?()
    }
}
