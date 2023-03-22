//
//  ResourceBookings.swift
//  tumble-ios
//
//  Created by Adis Veletanlic on 2023-02-14.
//

import SwiftUI

struct ResourceBookings: View {
    
    @ObservedObject var parentViewModel: AccountPageViewModel
    @State private var selectedPickerDate: Date = Date.now
    
    var body: some View {
        VStack {
            switch parentViewModel.resourceBookingPageState {
            case .loading:
                CustomProgressIndicator()
            case .loaded:
                Text("Loaded")
            case .error:
                Info(title: "Could not contact the server", image: "wifi.exclamationmark")
            }
        }
        .frame(
            maxWidth: .infinity,
            maxHeight: .infinity,
            alignment: .top
        )
        .background(Color.background)
        .onAppear {
            parentViewModel.getAllResourceData()
        }
    }
}

struct ResourceBookings_Previews: PreviewProvider {
    static var previews: some View {
        ResourceBookings(parentViewModel: ViewModelFactory.shared.makeViewModelAccountPage())
    }
}
