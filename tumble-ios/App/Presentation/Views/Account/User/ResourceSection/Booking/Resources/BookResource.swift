//
//  BookResource.swift
//  tumble-ios
//
//  Created by Adis Veletanlic on 2023-03-22.
//

import SwiftUI

struct BookResource: View {
    
    @ObservedObject var parentViewModel: AccountViewModel
    @Binding var selectedPickerDate: Date
    
    var body: some View {
        /// List of all available buildings that
        /// allow for booking rooms
        VStack {
            ForEach(parentViewModel.allResources!, id: \.self.id) { resource in
                let availableCounts = resource.availabilities.countAvailable()
                NavigationLink(destination: {
                    ResourceSelection(
                        parentViewModel: parentViewModel,
                        resource: resource,
                        selectedPickerDate: selectedPickerDate
                    ).customNavigationBackButton(
                        previousPage: "Date"
                    )
                }, label: {
                    HStack (spacing: 0) {
                        VStack (alignment: .leading, spacing: 10) {
                            HStack {
                                Text(resource.name ?? "No name")
                                    .font(.system(size: 18, weight: .medium))
                                    .foregroundColor(.onSurface)
                                    .lineLimit(1)
                                    .truncationMode(.tail)
                                Spacer()
                            }
                            HStack {
                                Image(systemName: "calendar.badge.clock")
                                    .font(.system(size: 15))
                                    .foregroundColor(.onSurface.opacity(0.7))
                                Text("\(selectedPickerDate.formatDate())")
                                    .font(.system(size: 15))
                                    .foregroundColor(.onSurface.opacity(0.7))
                            }
                            HStack {
                                Image(systemName: "clock.arrow.circlepath")
                                    .font(.system(size: 15))
                                    .foregroundColor(.onSurface.opacity(0.7))
                                Text("Available timeslots: \(availableCounts)")
                                    .font(.system(size: 15))
                                    .foregroundColor(.onSurface.opacity(0.7))
                            }
                        }
                        .padding()
                        Spacer()
                    }
                })
                .disabled(!(availableCounts > 0))
                .buttonStyle(ResourceBookingButtonStyle())
                .padding(.horizontal)
            }
        }
        .padding(.top)
    }
}
