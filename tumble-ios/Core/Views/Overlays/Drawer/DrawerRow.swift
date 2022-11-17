//
//  DrawerRow.swift
//  tumble-ios
//
//  Created by Adis Veletanlic on 11/17/22.
//

import SwiftUI

struct DrawerRow: View {
    let title: String
    let image: String
    var body: some View {
        HStack {
            Text(title)
                .font(.system(size: 18))
            Spacer()
            Image(systemName: image)
                .font(.system(size: 22))
                .padding(.trailing, 5)
            
            
        }.padding(.bottom, 25)
    }
}
