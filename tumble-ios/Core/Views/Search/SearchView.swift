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
            VStack (spacing: 0) {
                if (viewModel.status == .initial) {
                    HStack (alignment: .center) {
                        Text("Find schedules by program, course or name")
                            .font(.title2)
                            .padding(20)
                            .foregroundColor(Color("BackgroundColor"))
                            .cornerRadius(10)
                            .background(Color("PrimaryColor").opacity(0.75))
                            .clipShape(RoundedRectangle(cornerRadius: 25, style: .continuous))
                            .padding(20)
                    }
                    .animation(.easeInOut)
                }
                SearchBar()
                    .environmentObject(viewModel)
                    .padding(.leading, 30)
                    .padding(.trailing, 30)
                    .padding(.top, 15)
                    .onSubmit {
                        if(!viewModel.searchText.trimmingCharacters(in: .whitespaces).isEmpty) {
                            viewModel.status = .loading
                            viewModel.fetchResults(searchQuery: viewModel.searchText)
                        }
                    }
                Spacer()
                if (viewModel.status == .loading) {
                    ProgressView()
                    Spacer()
                }
                if (viewModel.status == .loaded) {
                    VStack {
                        HStack {
                            Text("Results: \(viewModel.numberOfSearchResults)")
                                .font(.headline)
                                .padding(.leading, 20)
                                .padding(.top, 20)
                                .padding(.bottom, 10)
                            Spacer()
                        }
                        List(viewModel.searchResults, id: \.id) { programme in
                            ProgrammeCardView(logo: viewModel.school.logo, programme: programme)
                                .onTapGesture(perform: {
                                    // stub
                                })
                        }
                    }
                }
            }
            
        }
    }
}
