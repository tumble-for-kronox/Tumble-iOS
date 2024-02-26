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
            Image(systemName: "xmark")
                .foregroundColor(.onBackground)
                .font(.system(size: 24, weight: .medium))
        })
        .padding()
    }
}

