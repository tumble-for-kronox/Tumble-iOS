//
//  BookmarksViewModel.swift
//  tumble-ios
//
//  Created by Adis Veletanlic on 11/21/22.
//

import Foundation
import SwiftUI
import Combine
import RealmSwift

final class BookmarksViewModel: ObservableObject {
    
    let viewModelFactory: ViewModelFactory = ViewModelFactory()
    let scheduleViewTypes: [BookmarksViewType] = BookmarksViewType.allValues
    
    @Inject var preferenceService: PreferenceService
    @Inject var kronoxManager: KronoxManager
    @Inject var schoolManager: SchoolManager
    
    @Published var status: BookmarksViewStatus = .loading
    @Published var bookmarks: [Bookmark]?
    @Published var defaultViewType: BookmarksViewType = .list
    @Published var eventSheet: EventDetailsSheetModel? = nil
    @ObservedResults(Schedule.self) var schedules
    
    private var cancellables = Set<AnyCancellable>()
    var hiddenBookmarks: [String] {
        return bookmarks?.filter { !$0.toggled }.map { $0.id } ?? []
    }
    
    init () {
        setUpDataPublishers()
        defaultViewType = preferenceService.getDefaultViewType()
    }
    
    func setUpDataPublishers() -> Void {
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            guard let self else { return }
            // Set up publisher to update schedules when data stores are updated
            let bookmarksPublisher = self.preferenceService.$bookmarks

            bookmarksPublisher
                .receive(on: DispatchQueue.main)
                .sink { bookmarks in
                    DispatchQueue.main.async {
                        self.handleNewBookmarks(newBookmarks: bookmarks)
                    }
                }
                .store(in: &self.cancellables)
        }
    }

    
    // If bookmarks in preferences are modified in app
    func handleNewBookmarks(newBookmarks: [Bookmark]?) -> Void {
        status = .loading
        self.bookmarks = newBookmarks
        switch newBookmarks {
        case .none:
            status = .uninitialized
        case .some(let bookmarks) where bookmarks.isEmpty:
            status = .uninitialized
        case .some(let bookmarks) where bookmarks.filter({ $0.toggled }).isEmpty:
            status = .hiddenAll
        case .some:
            print("Has some: \(newBookmarks?.map { $0.id })")
            status = .loaded
        }
    }
    
    func createViewModelEventSheet(event: Event) -> EventDetailsSheetViewModel {
        return viewModelFactory.makeViewModelEventDetailsSheet(event: event)
    }
    
    func onChangeViewType(viewType: BookmarksViewType) -> Void {
        let viewTypeIndex: Int = scheduleViewTypes.firstIndex(of: viewType)!
        preferenceService.setViewType(viewType: viewTypeIndex)
        defaultViewType = viewType
    }
}
