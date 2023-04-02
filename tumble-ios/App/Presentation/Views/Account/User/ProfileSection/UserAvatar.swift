//
//  UserAvatar.swift
//  tumble-ios
//
//  Created by Adis Veletanlic on 2023-02-13.
//

import SwiftUI

struct UserAvatar: View {
    
    let name: String
    @Binding var collapsedHeader: Bool
    
    var body: some View {
        Text(name.abbreviate())
            .font(.system(size: collapsedHeader ? 20 : 40, weight: .semibold))
            .foregroundColor(.onPrimary)
            .padding()
            .background(Circle().fill(Color.green.opacity(0.7)))
    }
}

