//
//  SchedulePreviewView.swift
//  tumble-ios
//
//  Created by Adis Veletanlic on 11/18/22.
//

import SwiftUI

struct SearchPreview: View {
    
    @ObservedObject var viewModel: SearchPreviewViewModel
    
    var body: some View {
        VStack {
            DraggingPill()
            HStack {
                Spacer()
                BookmarkButton(
                    bookmark: bookmark,
                    buttonState: $viewModel.buttonState)
            }
            switch viewModel.status {
            case .loaded:
                SearchPreviewList(
                    viewModel: viewModel
                )
            case .loading:
                CustomProgressIndicator()
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
            case .error:
                if let failure = viewModel.errorMessage {
                    Info(title: failure, image: nil)
                } else {
                    Info(title: NSLocalizedString("Something went wrong", comment: ""), image: nil)
                }
            case .empty:
                Info(title: NSLocalizedString("Schedule seems to be empty", comment: ""), image: nil)
            }
        }
        .frame(
              minWidth: 0,
              maxWidth: .infinity,
              minHeight: 0,
              maxHeight: .infinity,
              alignment: .center
            )
        .background(Color.background)
    }
    
    func bookmark() -> Void {
        viewModel.bookmark()
    }
}

