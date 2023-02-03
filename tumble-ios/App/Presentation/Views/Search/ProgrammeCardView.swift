//
//  ProgrammeSearchResult.swift
//  tumble-ios
//
//  Created by Adis Veletanlic on 11/18/22.
//

import SwiftUI

struct ProgrammeCardView: View {
    //var programme: Response.Programme
    let programme: Response.Programme
    let universityImage: Image?
    var body: some View {
        HStack {
            VStack(alignment:.leading) {
                Text(programme.subtitle.trimmingCharacters(in: .whitespaces))
                    .programmeTitle()
                HStack {
                    if universityImage != nil {
                        universityImage!
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 20, height: 20)
                            .cornerRadius(2.5)
                    }
                    Text(programme.title)
                        .programmeSubTitle()
                }
            }
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.surface)
        .cornerRadius(10)
        .padding()
        
    }
}
