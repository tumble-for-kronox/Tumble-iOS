//
//  ResourceBookings.swift
//  tumble-ios
//
//  Created by Adis Veletanlic on 2023-02-14.
//

import SwiftUI

struct ResourceBookings: View {
    
    @ObservedObject var parentViewModel: AccountViewModel
    @State private var selectedPickerDate: Date = Date.now
    
    var body: some View {
        ScrollView (showsIndicators: false) {
            ResourceDatePicker(date: $selectedPickerDate)
            switch parentViewModel.resourceBookingPageState {
            case .loading:
                CustomProgressIndicator()
                    .frame(
                        maxWidth: .infinity,
                        maxHeight: .infinity,
                        alignment: .center
                    )
            case .loaded:
                BookResource(parentViewModel: parentViewModel, selectedPickerDate: $selectedPickerDate)
            case .error:
                switch parentViewModel.error?.statusCode {
                case 404:
                    Info(title: "No rooms available on weekends", image: nil)
                default:
                    Info(title: "Something went wrong", image: nil)
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
            parentViewModel.getAllResourceData(date: selectedPickerDate)
        }
        .onChange(of: selectedPickerDate, perform: { _ in
            
            parentViewModel.getAllResourceData(date: selectedPickerDate)
        })
    }
}

struct ResourceBookings_Previews: PreviewProvider {
    static var previews: some View {
        ResourceBookings(parentViewModel: ViewModelFactory.shared.makeViewModelAccount())
    }
}
