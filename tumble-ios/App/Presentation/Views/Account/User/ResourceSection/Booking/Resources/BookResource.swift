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
        VStack {
            Divider()
                .foregroundColor(.onBackground)
            /// List of all available buildings that
            /// allow for booking rooms
            VStack {
                ForEach(parentViewModel.allResources!, id: \.self.id) { resource in
                    NavigationLink(destination: {
                        ResourceSelection(
                            parentViewModel: parentViewModel,
                            resource: resource
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
                                    Image(systemName: "mappin.and.ellipse")
                                        .font(.system(size: 15))
                                        .foregroundColor(.onSurface.opacity(0.7))
                                    Text("Available: \(resource.availabilities.countAvailable())")
                                        .font(.system(size: 15))
                                        .foregroundColor(.onSurface.opacity(0.7))
                                }
                            }
                            .padding()
                            Spacer()
                        }
                    })
                    .buttonStyle(ResourceBookingButtonStyle())
                    .padding(.horizontal)
                }
            }
            .padding(.top)
            Spacer()
        }
    }
}
