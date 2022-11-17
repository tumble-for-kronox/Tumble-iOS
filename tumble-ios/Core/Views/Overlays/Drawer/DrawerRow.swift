//
//  DrawerRow.swift
//  tumble-ios
//
//  Created by Adis Veletanlic on 11/17/22.
//

import SwiftUI

struct DrawerRow: View {
    let title: String
    let description: String
    let image: String
    var body: some View {
        HStack {
            VStack {
                Text(title)
                    .bold()
                    .font(.system(size: 18))
                    .frame(maxWidth: .infinity, alignment: .leading)
                Text(description)
                    .font(.system(size: 14))
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            
            Spacer()
            Image(systemName: image)
                .font(.system(size: 22))
        }
        .padding(.leading, 20)
        .padding(.trailing, 25)
        .padding(.bottom, 10)
        
    }
}
