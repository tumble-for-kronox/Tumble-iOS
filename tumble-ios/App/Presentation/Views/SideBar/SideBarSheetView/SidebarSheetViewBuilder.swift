//
//  SidebarSheetBuilder.swift
//  tumble-ios
//
//  Created by Adis Veletanlic on 2023-02-09.
//

import SwiftUI

struct SidebarSheetViewBuilder<Content : View>: View {
    
    let header: String
    let content: Content
    
    init(header: String, @ViewBuilder content: () -> Content) {
        self.content = content()
        self.header = header
    }
    
    var body: some View {
        VStack (spacing: 0) {
            HStack {
                Text(header)
                    .sheetTitle()
                Spacer()
            }
            content
            Spacer()
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}
