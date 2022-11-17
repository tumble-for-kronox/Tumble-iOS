//
//  SearchBar.swift
//  tumble-ios
//
//  Created by Adis Veletanlic on 11/17/22.
//

import SwiftUI

struct SearchBar: View {
    @EnvironmentObject var viewModel: SearchView.SearchViewModel
    var body: some View {
        ZStack {
            Color(.gray).opacity(0.15)
            HStack {
                 Image(systemName: "magnifyingglass")
                TextField("Search schedules..", text: $viewModel.searchText)
             }
                 .foregroundColor(.gray)
                 .padding(.leading, 13)
        }
        .frame(height: 40)
         .cornerRadius(13)
         .padding()
    }
}

struct SearchBar_Previews: PreviewProvider {
    static var previews: some View {
        SearchBar()
    }
}
