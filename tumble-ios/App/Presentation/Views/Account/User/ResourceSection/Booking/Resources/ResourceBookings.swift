//
//  ResourceBookings.swift
//  tumble-ios
//
//  Created by Adis Veletanlic on 2023-02-14.
//

import SwiftUI

struct ResourceBookings: View {
    
    @ObservedObject var viewModel: ResourceViewModel
    @State private var selectedPickerDate: Date = Date.now
    
    var body: some View {
        VStack {
            ScrollView (showsIndicators: false) {
                ResourceDatePicker(date: $selectedPickerDate)
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
                    BookResource(parentViewModel: viewModel, selectedPickerDate: $selectedPickerDate)
                case .error:
                    VStack {
                        switch viewModel.error?.statusCode {
                        case 404:
                            Info(title: "No rooms available on weekends", image: "moon.stars")
                        default:
                            Info(title: "Could not contact the server", image: nil)
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
        .background(Color(UIColor.systemBackground))
        .onAppear {
            viewModel.getAllResourceData(date: selectedPickerDate)
        }
        .onChange(of: selectedPickerDate, perform: { _ in
            viewModel.getAllResourceData(date: selectedPickerDate)
        })
    }
}

struct ResourceBookings_Previews: PreviewProvider {
    static var previews: some View {
        ResourceBookings(viewModel: ViewModelFactory.shared.makeViewModelResource())
    }
}
