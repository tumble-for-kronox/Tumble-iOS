//
//  BookResource.swift
//  tumble-ios
//
//  Created by Adis Veletanlic on 2023-03-22.
//

import SwiftUI

struct BookResource: View {
    
    @ObservedObject var parentViewModel: AccountViewModel
    @State private var selectedPickerDate: Date = Date.now
    
    var body: some View {
        ScrollView (showsIndicators: false) {
            ResourceDatePicker(date: $selectedPickerDate)
            Divider()
                .foregroundColor(.onBackground)
            /// List of all available buildings that
            /// allow for booking rooms
            VStack {
                ForEach(parentViewModel.allResources!, id: \.self.id) { resource in
                    Button(action: {
                        
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
                                    Text("Locations: \(resource.locationIDS?.count ?? 0)")
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

struct BookResource_Previews: PreviewProvider {
    static var previews: some View {
        BookResource(parentViewModel: ViewModelFactory.shared.makeViewModelAccount())
    }
}
