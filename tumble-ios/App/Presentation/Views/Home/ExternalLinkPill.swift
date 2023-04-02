//
//  LinkPillView.swift
//  tumble-ios
//
//  Created by Adis Veletanlic on 2023-02-03.
//

import SwiftUI

struct ExternalLinkPill: View {
    
    let title: String
    let image: String
    let url: URL?
    let color: Color
    
    @Binding var collapsedHeader: Bool
    
    var body: some View {
        Button(action: {
            if url != nil {
                UIApplication.shared.open(self.url!)
            }
        }, label: {
            HStack {
                Image(systemName: image)
                    .font(.system(size: 14))
                    .foregroundColor(.onPrimary)
                if !collapsedHeader {
                    Text(title)
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundColor(.onPrimary)
                }
            }
        })
        .buttonStyle(ExternalLinkPillStyle(color: color))
    }
}
