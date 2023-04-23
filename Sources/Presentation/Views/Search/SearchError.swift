//
//  SearchErrorView.swift
//  Tumble
//
//  Created by Adis Veletanlic on 11/28/22.
//

import SwiftUI

struct SearchError: View {
    var body: some View {
        VStack(alignment: .center) {
            Spacer()
            Image(systemName: "wifi.exclamationmark")
                .font(.system(size: 24))
                .padding(.bottom, 20)
            Text(NSLocalizedString("Looks like something went wrong", comment: ""))
                .font(.headline)
                .foregroundColor(.onBackground)
                .padding(.bottom, 25)
            Spacer()
        }
        .padding(.bottom, 10)
        .padding(.leading, 15)
        .padding(.trailing, 15)
    }
}
