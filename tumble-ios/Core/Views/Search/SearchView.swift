//
//  SearchView.swift
//  tumble-ios
//
//  Created by Adis Veletanlic on 11/17/22.
//

import SwiftUI

struct SearchView: View {
    @StateObject var viewModel: SearchViewModel = SearchViewModel()
    var body: some View {
        ZStack {
            VStack (spacing: 0){
                HStack {
                    Text("Find schedules by program, course or name")
                        .font(.system(size: 24, weight: .bold, design: .default))
                        .padding(.leading, 20)
                        .padding(.top, 10)
                    Spacer()
                }
                SearchBar()
                    .environmentObject(viewModel)
                    .padding(.top, 5)
                Spacer()
            }
            
        }
    }
}

struct SearchView_Previews: PreviewProvider {
    static var previews: some View {
        SearchView()
    }
}
