//
//  User.swift
//  Tumble
//
//  Created by Adis Veletanlic on 2023-02-13.
//

import SwiftUI

struct UserOverview: View {
    @ObservedObject var viewModel: AccountViewModel
    @ObservedObject var appController: AppController = .shared
        
    @State private var collapsedHeader: Bool = false
    
    var body: some View {
        VStack {
            HStack {
                if let name = viewModel.userDisplayName,
                   let username = viewModel.username
                {
                    UserAvatar(name: name, collapsedHeader: $collapsedHeader)
                        .padding(.trailing, 5)
                    VStack(alignment: .leading, spacing: 0) {
                        Text(name)
                            .font(.system(size: collapsedHeader ? 20 : 22, weight: .semibold))
                        if !collapsedHeader {
                            Text(username)
                                .font(.system(size: 16, weight: .regular))
                            Text(viewModel.schoolName)
                                .font(.system(size: 14, weight: .semibold))
                                .padding(.top, 10)
                        }
                    }
                    .padding(10)
                }
            }
            .padding(.horizontal, 15)
            .frame(maxWidth: .infinity, alignment: .leading)
            Divider()
                .foregroundColor(.onBackground)
                .padding(.horizontal, 15)
            Resources(
                parentViewModel: viewModel,
                getResourcesAndEvents: getResourcesAndEvents,
                collapsedHeader: $collapsedHeader
            )
        }
        .background(Color.background)
    }
    
    fileprivate func getResourcesAndEvents() {
        Task {
            await viewModel.getUserBookingsForSection()
            await viewModel.getUserEventsForSection()
        }
    }
}
