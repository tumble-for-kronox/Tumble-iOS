//
//  CustomList.swift
//  tumble-ios
//
//  Created by Adis Veletanlic on 2023-04-02.
//

import SwiftUI

struct CustomList<Content: View>: View {
    let content: () -> Content
    
    init(@ViewBuilder content: @escaping () -> Content) {
        self.content = content
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                content()
            }
        }
        .background(Color.background)
    }
}
