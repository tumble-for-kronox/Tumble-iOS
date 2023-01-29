//
//  ProgrammeSearchResult.swift
//  tumble-ios
//
//  Created by Adis Veletanlic on 11/18/22.
//

import SwiftUI

struct ProgrammeCardView: View {
    var programme: Response.Programme
    var body: some View {
        HStack {
            VStack(alignment:.leading) {
                Text(programme.subtitle.trimmingCharacters(in: .whitespaces))
                    .programmeTitle()
                HStack {
                    Image(systemName: "menucard")
                        .font(.system(size: 17))
                    Text(programme.title)
                        .programmeSubTitle()
                }
            }
        }
        .padding()
    }
}
