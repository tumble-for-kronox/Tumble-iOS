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
    
    var body: some View {
        HStack {
            Text(locationId)
                .font(.system(size: 20, weight: .semibold))
                .foregroundColor(.onSurface)
            Spacer()
            Button(action: {
                onBook()
            }, label: {
                Text("Book")
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundColor(.onPrimary)
                    .padding()
            })
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

