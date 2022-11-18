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
        @Published var isEditing: Bool = false
        @Published var status: SearchStatus = .initial
        @Published var numberOfSearchResults: Int = 0
        @Published var searchResults: [API.Types.Response.Programme] = []
        @Published var scheduleForPreview: API.Types.Response.Schedule? = nil
        @Published var presentPreview: Bool = false
        @Published var school: School = {
            var id: Int = UserDefaults.standard.getDefault(key: UserDefaults.StoreKey.school.rawValue) as! Int
            return schools.first(where: {$0.id == id})!
        } ()
        
        private var client: API.Client = API.Client.shared
        
        func fetchResults(searchQuery: String) -> Void {
            print("Got here ..")
            client.get(.searchProgramme(searchQuery: searchQuery, schoolId: String(school.id))) { (result: Result<API.Types.Response.Search, API.Types.Error>) in
                DispatchQueue.main.async {
                    
                    switch result {
                    case .success(let success):
                        self.status = SearchStatus.loading
                        self.parseSearchResults(success)
                    case .failure(let failure):
                        self.status = SearchStatus.error
                        print("error")
                    }
                }
            }
        }
        
        private func parseSearchResults(_ results: API.Types.Response.Search) -> Void {
            var localResults = [API.Types.Response.Programme]()
            self.numberOfSearchResults = results.count
            for result in results.items {
                localResults.append(result)
            }
            self.searchResults = localResults
            self.status = .loaded
        }
        
        private func loadScheduleForPreview(schedule: API.Types.Response.Schedule) -> Void {
            
        }
        
        func clearSearch() -> Void {
            self.isEditing = false
            self.searchText = ""
            self.status = .initial
            self.searchResults = []
            self.numberOfSearchResults = 0
        }
        
        func loadSchedule(programme: API.Types.Response.Programme) -> Void {
            self.presentPreview = true
            client.get(.schedule(scheduleId: programme.id, schoolId: String(school.id))) { (result: Result<API.Types.Response.Schedule, API.Types.Error>) in
                DispatchQueue.main.async {
                    switch result {
                    case .success(let schedule):
                        self.scheduleForPreview = schedule
                        self.presentPreview = true
                    case .failure(let failure):
                        self.status = SearchStatus.error
                    }
                }
            }
        }
    }
}
