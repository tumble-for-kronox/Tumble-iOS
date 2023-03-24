//
//  RoomContainerCar.swift
//  tumble-ios
//
//  Created by Adis Veletanlic on 3/23/23.
//

import SwiftUI

struct RoomContainerCard: View {
    
    let onBook: () -> Void
    let locationId: String
    @Binding var bookingButtonState: BookingButtonState
    
    var body: some View {
        HStack {
            Text(locationId)
                .font(.system(size: 20, weight: .semibold))
                .foregroundColor(.onSurface)
            Spacer()
            Button(action: {
                if bookingButtonState != .booked {
                    onBook()
                }
            }, label: {
                switch bookingButtonState {
                case .loading:
                    CustomProgressIndicator(tint: .onPrimary)
                        .padding()
                case .booked:
                    Text("Booked")
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundColor(.onPrimary)
                        .padding()
                case .available:
                    Text("Book")
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundColor(.onPrimary)
                        .padding()
                }
            })
            .disabled(bookingButtonState == .booked)
            .buttonStyle(BookButtonStyle())
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: 80)
        .background(Color.surface)
        .cornerRadius(20)
        .padding(.horizontal, 15)
        .padding(.vertical, 10)
    }
}

