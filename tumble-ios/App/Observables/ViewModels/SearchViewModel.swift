//
//  SearchView-ViewModel.swift
//  tumble-ios
//
//  Created by Adis Veletanlic on 11/17/22.
//

import Foundation
import SwiftUI
import Combine

@MainActor final class SearchViewModel: ObservableObject {
    
    let viewModelFactory: ViewModelFactory = ViewModelFactory.shared
    
    @Inject var preferenceService: PreferenceService
    @Inject var kronoxManager: KronoxManager
    @Inject var notificationManager: NotificationManager
    @Inject var schoolManager: SchoolManager
    
    @Published var status: SearchStatus = .initial
    @Published var programmeSearchResults: [Response.Programme] = []
    @Published var courseColors: CourseAndColorDict? = nil
    @Published var schoolId: Int = -1
    @Published var errorMessageSearch: String? = nil
    @Published var searchPreviewModel: SearchPreviewModel? = nil
    @Published var universityImage: Image? = nil

    private var cancellables = Set<AnyCancellable>()
    
    init() {
        initialisePipelines()
        loadData()
    }
    
    func loadData() -> Void {
        schoolId = preferenceService.getDefaultSchool() ?? -1
        universityImage = self.schoolManager.getSchools().first(where: { $0.id == schoolId })?.logo ?? nil
    }
    
    func initialisePipelines() -> Void {
        preferenceService.$schoolId
            .sink { [weak self] schoolId in
                guard let self else { return }
                self.schoolId = schoolId
                self.universityImage = self.schoolManager.getSchools().first(where: { $0.id == schoolId })?.logo ?? nil
                self.resetSearchResults()
            }
            .store(in: &cancellables)
    }
    
    func createSearchPreviewViewModel(scheduleId: String) -> SearchPreviewViewModel {
        viewModelFactory.makeViewModelSearchPreview(scheduleId: scheduleId)
    }
    
    func onSearchProgrammes(searchQuery: String) -> Void {
        self.status = .loading
        let _ = kronoxManager.get(.searchProgramme(
            searchQuery: searchQuery,
            schoolId: String(schoolId))) { [weak self] (result: Result<Response.Search, Response.ErrorMessage>) in
                guard let self = self else { return }
                switch result {
                case .success(let result):
                    self.parseSearchResults(result)
                case .failure(let failure):
                    switch failure.statusCode {
                    case 204:
                        self.errorMessageSearch = NSLocalizedString("There are no schedules that match your search", comment: "")
                        self.status = SearchStatus.error
                    default:
                        self.errorMessageSearch = NSLocalizedString("Something went wrong", comment: "")
                        self.status = SearchStatus.error
                    }
                    AppLogger.shared.debug("Encountered error when trying to search for programme \(searchQuery): \(failure)")
                }
        }
    }
    
    
    func onClearSearch(endEditing: Bool) -> Void {
        if (endEditing) {
            self.programmeSearchResults = []
            self.status = .initial
        }
    }
    
    
    func parseSearchResults(_ results: Response.Search) -> Void {
        self.programmeSearchResults = results.items.map { $0 }
        self.status = .loaded
    }
    
    func resetSearchResults() -> Void {
        self.programmeSearchResults = []
        self.status = .initial
    }
    
}
