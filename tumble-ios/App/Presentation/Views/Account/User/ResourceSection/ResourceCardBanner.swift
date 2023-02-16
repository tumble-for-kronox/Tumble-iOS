//
//  ResourceCardBanner.swift
//  tumble-ios
//
//  Created by Adis Veletanlic on 2023-02-16.
//

import SwiftUI

struct ResourceCardBanner: View {
    
    let timeSpan: String
    
    var body: some View {
        HStack {
            Circle()
                .foregroundColor(Color.primary)
                .frame(height: 7)
            Text(timeSpan)
                .timeSpanCard()
        }
        .padding(.trailing)
    }
}

