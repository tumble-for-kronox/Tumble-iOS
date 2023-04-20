//
//  SheetTitle.swift
//  tumble-ios
//
//  Created by Adis Veletanlic on 2023-04-05.
//

import SwiftUI

struct SheetTitle: View {
    let title: String
    
    var body: some View {
        HStack {
            Spacer()
            Text(title)
                .sheetTitle()
            Spacer()
        }
        .padding(.top, 10)
    }
}
