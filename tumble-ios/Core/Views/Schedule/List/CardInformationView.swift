//
//  CardInformationView.swift
//  tumble-ios
//
//  Created by Adis Veletanlic on 2023-01-26.
//

import SwiftUI

struct CardInformationView: View {
    let title: String
    let courseName: String
    let location: String
    
    var body: some View {
        VStack (alignment: .leading) {
            Text(title)
                .font(.title2)
                .foregroundColor(Color("OnSurface"))
                .padding(.leading, 25)
                .padding(.trailing, 25)
                .padding(.bottom, 2.5)
            VStack {
                Text(courseName)
                    .font(.title3)
                    .foregroundColor(Color("OnSurface"))
                    .padding(.leading, 25)
                    .padding(.bottom, 10)
                Spacer()
            }
            HStack {
                Spacer()
                Text(location)
                    .font(.title3)
                    .foregroundColor(Color("OnSurface"))
                Image(systemName: "location")
                    .font(.title3)
                    .foregroundColor(Color("OnSurface"))
                    .padding(.trailing, 5)
            }
            .padding(.trailing, 10)
            Spacer()
        }
    }
}
