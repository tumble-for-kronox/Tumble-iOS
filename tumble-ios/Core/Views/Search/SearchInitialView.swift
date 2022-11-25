//
//  SearchInitialView.swift
//  tumble-ios
//
//  Created by Adis Veletanlic on 11/20/22.
//

import SwiftUI

struct SearchInitialView: View {
    var body: some View {
        VStack (alignment: .center) {
            Spacer()
            Image(systemName: "lasso")
                .font(.system(size: 24))
                .foregroundColor(Color("OnBackground"))
            Text("This is where you find your schedules")
                .font(.headline)
                .foregroundColor(Color("OnBackground"))
                .padding(20)
                .padding(.bottom, 25)
                .padding(.leading, 5)
            Spacer()
                
        }
        .padding(.bottom, 10)
        .padding(.leading, 15)
        .padding(.trailing, 15)
    }
}
