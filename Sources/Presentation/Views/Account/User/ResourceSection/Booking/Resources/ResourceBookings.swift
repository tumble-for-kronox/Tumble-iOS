//
//  ResourceBookings.swift
//  tumble-ios
//
//  Created by Adis Veletanlic on 2023-02-14.
//

import SwiftUI

struct ResourceBookings: View {
    @ObservedObject var viewModel: ResourceViewModel
    let updateBookingNotifications: () -> Void
    
    var body: some View {
        VStack {
            ScrollView(showsIndicators: false) {
                ResourceDatePicker(date: $viewModel.selectedPickerDate)
                Divider()
                    .foregroundColor(.onBackground)
                switch viewModel.resourceBookingPageState {
                case .loading:
                    VStack {
                        CustomProgressIndicator()
                    }
                    .frame(
                        maxWidth: .infinity,
                        minHeight: 200,
                        maxHeight: .infinity,
                        alignment: .center
                    )
                case .loaded:
                    ResourceLocationsList(
                        parentViewModel: viewModel,
                        selectedPickerDate: $viewModel.selectedPickerDate,
                        updateBookingNotifications: updateBookingNotifications
                    )
                case .error:
                    VStack {
                        switch viewModel.error?.statusCode {
                        case 404:
                            Info(title: NSLocalizedString("No rooms available on weekends", comment: ""), image: "moon.stars")
                        default:
                            Info(title: NSLocalizedString("Could not contact the server, try again later", comment: ""), image: nil)
                        }
                    }
                    .frame(
                        maxWidth: .infinity,
                        minHeight: 200,
                        maxHeight: .infinity,
                        alignment: .center
                    )
                }
            }
        }
        .frame(
            maxWidth: .infinity,
            maxHeight: .infinity,
            alignment: .top
        )
        .background(Color.background)
        .onAppear {
            viewModel.getAllResourceData(date: viewModel.selectedPickerDate)
        }
        .onChange(of: viewModel.selectedPickerDate, perform: { _ in
            viewModel.getAllResourceData(date: viewModel.selectedPickerDate)
        })
    }
}
