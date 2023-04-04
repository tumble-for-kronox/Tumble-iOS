//
//  SearchButton.swift
//  tumble-ios
//
//  Created by Adis Veletanlic on 4/1/23.
//

import SwiftUI

struct SearchButton: View {
    
    let search: () -> Void
    
    var body: some View {
        Button(action: search, label: {
            Image(systemName: "magnifyingglass")
                .foregroundColor(.gray)
                .font(.system(size: 17, weight: .semibold))
                .padding(.leading, 5)
        })
    }
}
