//
//  ResourceCard.swift
//  tumble-ios
//
//  Created by Adis Veletanlic on 2023-02-16.
//

import SwiftUI

struct ResourceCard: View {
    
    let timeSpan: String
    let location: String?
    let title: String?
    
    init(timeSpan: String, location: String? = nil, title: String? = nil) {
        self.timeSpan = timeSpan
        self.location = location
        self.title = title
    }
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 7.5)
                .fill(Color.primary)
                
            Rectangle()
                .fill(Color.surface)
                .offset(x: 7.5)
                .cornerRadius(5, corners: [.topRight, .bottomRight])
            HStack {
                ResourceCardBanner(timeSpan: timeSpan)
                if let location = location {
                    Text(location)
                        .font(.system(size: 16, weight: .semibold))
                        .frame(maxWidth: .infinity, alignment: .trailing)
                } else if let title = title {
                    Text(title)
                        .font(.system(size: 16, weight: .semibold))
                        .frame(maxWidth: .infinity, alignment: .trailing)
                }
            }
            .padding(.trailing, 15)
            .padding(.leading, 20)
            .padding(.vertical, 10)
        }
        .frame(height: 45)
    }
}

