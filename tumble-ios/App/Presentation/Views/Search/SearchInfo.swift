//
//  SearchInitialView.swift
//  tumble-ios
//
//  Created by Adis Veletanlic on 11/20/22.
//

import SwiftUI

struct SearchInfo: View {
    var body: some View {
        VStack (alignment: .center) {
            Spacer()
            Image(systemName: "pencil.and.outline")
                .font(.system(size: 24))
                .foregroundColor(Color("OnBackground"))
                .padding(.bottom, 15)
            Text("This is where you find your schedules")
                .info()
            Spacer()
                
        }
        .padding(.bottom, 10)
        .padding(.leading, 15)
        .padding(.trailing, 15)
    }
}
