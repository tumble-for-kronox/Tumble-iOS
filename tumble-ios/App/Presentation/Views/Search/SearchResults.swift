//
//  SearchBodyView.swift
//  tumble-ios
//
//  Created by Adis Veletanlic on 11/20/22.
//

import SwiftUI

struct SearchResults: View {
    
    let searchText: String
    let numberOfSearchResults: Int
    let searchResults: [Response.Programme]
    let onOpenProgramme: (String) -> Void
    
    @Binding var universityImage: Image?
    
    var body: some View {
        VStack {
            HStack {
                Text("\(numberOfSearchResults) results for \"\(searchText)\"")
                    .searchResultsField()
                Spacer()
            }
            List(searchResults, id: \.id) { programme in
                ProgrammeCard(programme: programme, universityImage: universityImage)
                    .onTapGesture {
                        onOpenProgramme(programme.id)
                    }
            }
            .listStyle(PlainListStyle())
        }
    }
}
