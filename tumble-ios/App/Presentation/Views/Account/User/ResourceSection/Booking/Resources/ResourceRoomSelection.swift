//
//  ResourceRoomSelection.swift
//  tumble-ios
//
//  Created by Adis Veletanlic on 2023-03-22.
//

import SwiftUI

struct ResourceRoomSelection: View {
    
    @Binding var availabilityValues: [Response.AvailabilityValue]
    
    var body: some View {
        if availabilityValues.isEmpty {
            VStack {
                Info(title: "No available timeslots", image: "clock.arrow.circlepath")
            }.frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
        }
        else {
            ScrollView (showsIndicators: false) {
                ForEach(availabilityValues) { availabilityValue in
                    if let locationId = availabilityValue.locationID {
                        HStack {
                            Text("\(locationId)")
                                .font(.system(size: 20, weight: .semibold))
                                .foregroundColor(.onSurface)
                            Spacer()
                            Button(action: {}, label: {
                                Text("Book")
                                    .font(.system(size: 20, weight: .semibold))
                                    .foregroundColor(.onPrimary)
                            })
                            .padding()
                            .frame(minWidth: 85, maxHeight: 50)
                            .background(Color.primary)
                            .cornerRadius(20)
                        }
                        .padding()
                        .frame(maxWidth: .infinity, maxHeight: 80)
                        .background(Color.surface)
                        .cornerRadius(20)
                        .padding(.horizontal, 15)
                        .padding(.vertical, 10)
                    }
                }
            }
        }
    }
}

