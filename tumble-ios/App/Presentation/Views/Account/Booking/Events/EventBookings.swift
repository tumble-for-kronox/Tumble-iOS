//
//  ExamBookings.swift
//  tumble-ios
//
//  Created by Adis Veletanlic on 2023-02-14.
//

import SwiftUI

enum PageState {
    case loading
    case loaded
    case error
}

struct EventBookings: View {
    
    @EnvironmentObject var user: User
    @ObservedObject var viewModel: AccountPage.AccountPageViewModel
    @State private var state: PageState = .loading
    
    var body: some View {
        VStack {
            switch state {
            case .loading:
                CustomProgressIndicator()
            case .loaded:
                RegisteredEvents(registeredEvents: viewModel.completeUserEvent?.registeredEvents)
            case .error:
                Text("Error!")
            }
        }
        .onAppear {
            user.userEvents(completion: loadUserEvents)
        }
    }
 
    func loadUserEvents(events: Response.KronoxCompleteUserEvent?) {
        viewModel.loadUserEvents(events: events, completion: {
            self.state = .loaded
        })
    }
    
}
