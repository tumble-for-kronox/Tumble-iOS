//
//  SearchErrorView.swift
//  tumble-ios
//
//  Created by Adis Veletanlic on 11/28/22.
//

import SwiftUI

struct SearchErrorView: View {
    var body: some View {
        VStack (alignment: .center) {
            Spacer()
            Image(systemName: "exclamationmark.questionmark")
                .font(.system(size: 24))
                .padding(.bottom, 20)
            Text("Oops! Looks like something went wrong.")
                .font(.headline)
                .foregroundColor(Color("OnBackground"))
                .padding(.bottom, 25)
            Spacer()
        }
        .padding(.bottom, 10)
        .padding(.leading, 15)
        .padding(.trailing, 15)
    }
}

