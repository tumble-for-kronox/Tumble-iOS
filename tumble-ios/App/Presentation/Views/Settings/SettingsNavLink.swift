//
//  SettingsNavLink.swift
//  tumble-ios
//
//  Created by Adis Veletanlic on 3/30/23.
//

import SwiftUI

struct SettingsNavLink: View {
    
    let title: String
    let current: String?
    
    init(title: String, current: String? = nil) {
        self.title = title
        self.current = current
    }
    
    var body: some View {
        HStack {
            Text(title)
                .font(.system(size: 16))
                .foregroundColor(.onSurface)
            Spacer()
            if let current = current {
                Text(current)
                    .font(.system(size: 16))
                    .foregroundColor(.onSurface.opacity(0.7))
            }
        }
    }
}
