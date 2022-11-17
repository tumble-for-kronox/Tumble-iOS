//
//  SearchView-ViewModel.swift
//  tumble-ios
//
//  Created by Adis Veletanlic on 11/17/22.
//

import Foundation

enum SearchStatus {
    case initial
    case loading
    case loaded
    case error
    case empty
}

extension SearchView {
    @MainActor class SearchViewModel: ObservableObject {
        @Published var searchText: String = ""
        @Published var status: SearchStatus = .initial
        @Published var school: School = (UserDefaults.standard.getDefault(key: "SCHOOL") as! School)
        
        func fetchResults(searchQuery: String) -> Void {
            API.Client.shared.get(.searchProgramme(searchQuery: <#T##String#>, schoolId: <#T##String#>)) { (result: Result<API.Types.Response.Search, API.Types.Error>) in
                DispatchQueue.main.async {
                    switch result {
                    case .success(let success):
                        self.status = SearchStatus.loading
                        //self.parseSearchResults(success)
                    case .failure(let failure):
                        self.status = SearchStatus.error
                        // Show some error
                    }
                }
            }
        }
        
        //func parseSearchResults()
    }
}
