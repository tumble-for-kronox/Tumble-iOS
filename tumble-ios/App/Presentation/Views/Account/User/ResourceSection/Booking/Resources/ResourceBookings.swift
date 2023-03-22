//
//  ResourceBookings.swift
//  tumble-ios
//
//  Created by Adis Veletanlic on 2023-02-14.
//

import SwiftUI

struct ResourceBookings: View {
    
    @ObservedObject var parentViewModel: AccountViewModel
    
    var body: some View {
        VStack {
            switch parentViewModel.resourceBookingPageState {
            case .loading:
                CustomProgressIndicator()
            case .loaded:
                BookResource(parentViewModel: parentViewModel)
            case .error:
                Info(title: "Could not contact the server", image: "wifi.exclamationmark")
            }
        }
        .frame(
            maxWidth: .infinity,
            maxHeight: .infinity,
            alignment: .center
        )
        .background(Color.background)
        .onAppear {
            parentViewModel.getAllResourceData()
        }
    }
}

struct ResourceBookings_Previews: PreviewProvider {
    static var previews: some View {
        ResourceBookings(parentViewModel: ViewModelFactory.shared.makeViewModelAccount())
    }
}
