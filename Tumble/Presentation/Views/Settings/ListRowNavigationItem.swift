//
//  ListRowITem.swift
//  Tumble
//
//  Created by Adis Veletanlic on 2023-04-02.
//

import SwiftUI

struct ListRowNavigationItem: View {
    let title: String
    let current: String?
    let destination: AnyView
        
    init(
        title: String,
        current: String? = nil,
        destination: AnyView
    ) {
        self.title = title
        self.current = current
        self.destination = destination
    }
    
    var body: some View {
        NavigationLink(destination: destination, label: {
            HStack(spacing: 0) {
                Text(title)
                    .font(.system(size: 16, weight: .regular))
                    .foregroundColor(.onSurface)
                Spacer()
                if let current = current {
                    Text(current)
                        .font(.system(size: 16, weight: .regular))
                        .foregroundColor(.onSurface.opacity(0.7))
                        .padding(.trailing, 10)
                }
                Image(systemName: "chevron.right")
                    .font(.system(size: 15, weight: .medium))
                    .foregroundColor(.onSurface.opacity(0.3))
            }
            .padding(7)
        })
    }
}
