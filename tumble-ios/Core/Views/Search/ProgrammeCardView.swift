//
//  ProgrammeSearchResult.swift
//  tumble-ios
//
//  Created by Adis Veletanlic on 11/18/22.
//

import SwiftUI

struct ProgrammeCardView: View {
    var logo: Image
    var programme: API.Types.Response.Programme
    var body: some View {
        HStack {
            VStack(alignment:.leading) {
                Text(programme.subtitle.trimmingCharacters(in: .whitespaces))
                    .font(.headline)
                    .multilineTextAlignment(.leading)
                    .padding(.bottom, 10)
                HStack {
                    Image(systemName: "building.columns")
                        .font(.system(size: 16))
                    Text(programme.title)
                        .font(.subheadline)
                        .multilineTextAlignment(.leading)
                    
                }
            }
        }
        .padding()
    }
}
