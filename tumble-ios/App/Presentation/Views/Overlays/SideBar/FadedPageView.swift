//
//  FadedPageView.swift
//  tumble-ios
//
//  Created by Adis Veletanlic on 2023-02-01.
//

import SwiftUI

struct FadedPageView: View {
    
    let backgroundOpacity: CGFloat
    let offset: CGFloat
    let verticalPadding: CGFloat
    
    @Binding var showMenu: Bool
    
    var body: some View {
        Color.background.opacity(backgroundOpacity)
            .opacity(0.5)
            .cornerRadius(showMenu ? 15 : 0)
            .shadow(color: Color.dark.opacity(0.07), radius: 5, x: -5, y: 0)
            .offset(x: showMenu ? offset : 0)
            .padding(.vertical, verticalPadding)
    }
}

