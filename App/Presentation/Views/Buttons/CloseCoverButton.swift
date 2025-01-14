//
//  CloseCoverButton.swift
//  Tumble
//
//  Created by Adis Veletanlic on 7/15/23.
//

import SwiftUI

struct CloseCoverButton: View {
    
    let onClick: () -> Void
    
    var body: some View {
        Button(action: onClick, label: {
            Image(systemName: "xmark.circle.fill")
                .foregroundColor(.onBackground.opacity(0.6))
                .font(.system(size: 28, weight: .medium))
                .symbolRenderingMode(.hierarchical)
        })
        .padding(.trailing, Spacing.medium)
        .padding(.top, Spacing.small)
    }
}

