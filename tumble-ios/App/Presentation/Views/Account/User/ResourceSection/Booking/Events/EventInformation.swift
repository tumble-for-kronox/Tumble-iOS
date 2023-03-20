//
//  EventInformation.swift
//  tumble-ios
//
//  Created by Adis Veletanlic on 2023-02-15.
//

import SwiftUI

enum EventAvailabilityType {
    case upcoming
    case available
}

struct EventInformation: View {
    
    let title: String
    let signUp: String
    let type: EventAvailabilityType
    
    var body: some View {
        VStack (alignment: .leading) {
            Text(title)
                .font(.system(size: 18, weight: .semibold))
                .foregroundColor(.onSurface)
                .padding(.leading, 25)
                .padding(.trailing, 25)
                .padding(.bottom, 2.5)
            VStack {
                if signUp.isValidSignupDate() {
                    Text(type == .available ? "Available until \(signUp.toDate() ?? "")" : "Available at \(signUp.toDate() ?? "")")
                        .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(.onSurface)
                            .padding(.leading, 25)
                } else {
                    Text("Registration has passed")
                        .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(.onSurface)
                            .padding(.leading, 25)
                }
                Spacer()
            }
            
            Spacer()
        }
    }
}

