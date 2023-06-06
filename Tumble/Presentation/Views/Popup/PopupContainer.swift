//
//  PopupContainer.swift
//  Tumble
//
//  Created by Adis Veletanlic on 2023-06-06.
//

import SwiftUI

struct PopupContainer: View {
    
    let popup: Popup
    
    var body: some View {
        HStack {
            VStack (alignment: .leading, spacing: 0) {
                Text(popup.title)
                    .foregroundColor(.onPrimary)
                    .font(.system(size: 14, weight: .semibold))
                    .padding(.bottom, 5)
                if let message = popup.message {
                    Text(message)
                        .foregroundColor(.onPrimary)
                        .font(.system(size: 13, weight: .regular))
                }
            }
            Spacer()
            Image(systemName: popup.leadingIcon)
                .foregroundColor(.onPrimary)
        }
        .padding()
        .frame(maxWidth: .infinity, minHeight: 50)
        .background(Color.primary)
        .cornerRadius(10.0)
        .padding(15)
    }
}
