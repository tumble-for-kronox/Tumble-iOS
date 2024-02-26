//
//  CustomListGroup.swift
//  Tumble
//
//  Created by Adis Veletanlic on 2023-04-02.
//

import SwiftUI

struct SettingsListGroup<Content: View>: View {
    let content: () -> Content
    
    init(@ViewBuilder content: @escaping () -> Content) {
        self.content = content
    }
    
    var body: some View {
        VStack {
            content()
        }
        .padding(10)
        .frame(maxWidth: .infinity)
        .background(Color.surface)
        .cornerRadius(10)
        .padding([.horizontal, .vertical], 15)
    }
}
