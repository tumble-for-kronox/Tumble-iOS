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
        ScrollView (showsIndicators: false) {
            ForEach(availabilityValues) { availabilityValue in
                if let locationId = availabilityValue.locationID {
                    HStack {
                        Text("\(locationId)")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(.onSurface)
                        Spacer()
                        Button(action: {}, label: {
                            Text("Book")
                                .font(.system(size: 18, weight: .semibold))
                                .foregroundColor(.onSurface)
                        })
                        .padding()
                        .background(Color.primary)
                        .cornerRadius(20)
                    }
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.background)
                    .cornerRadius(20)
                }
            }
        }
    }
}

