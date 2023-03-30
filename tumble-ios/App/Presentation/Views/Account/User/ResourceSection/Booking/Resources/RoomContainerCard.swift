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
                .font(.system(size: 18, weight: .semibold))
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
                    HStack {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(.onPrimary)
                        Text(NSLocalizedString("Booked", comment: ""))
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(.onPrimary)
                    }
                    .padding()
                case .available:
                    HStack {
                        Image(systemName: "checkmark.circle")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(.onPrimary)
                        Text(NSLocalizedString("Book", comment: ""))
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(.onPrimary)
                    }
                    .padding()
                }
            })
            .disabled(bookingButtonState == .booked)
            .buttonStyle(BookButtonStyle())
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: 70)
        .background(Color.surface)
        .cornerRadius(20)
        .padding(.horizontal, 15)
        .padding(.vertical, 10)
    }
}

