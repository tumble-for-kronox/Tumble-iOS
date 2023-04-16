//
//  SchedulePageMainView-ViewModel.swift
//  tumble-ios
//
//  Created by Adis Veletanlic on 11/21/22.
//

import Foundation
import SwiftUI
import Combine

final class BookmarksViewModel: ObservableObject {
    
    let viewModelFactory: ViewModelFactory = ViewModelFactory()
    let scheduleViewTypes: [BookmarksViewType] = BookmarksViewType.allValues
    
    @Inject var scheduleService: ScheduleService
    @Inject var preferenceService: PreferenceService
    @Inject var courseColorService: CourseColorService
    @Inject var kronoxManager: KronoxManager
    @Inject var schoolManager: SchoolManager
    
    @Published var status: BookmarksViewStatus = .loading
    @Published var schedules: [ScheduleData] = []
    @Published var days: [DayUiModel] = []
    @Published var bookmarks: [Bookmark]?
    @Published var courseColors: CourseAndColorDict = [:]
    @Published var defaultViewType: BookmarksViewType = .list
    @Published var eventSheet: EventDetailsSheetModel? = nil
    
    private var cancellables = Set<AnyCancellable>()
    private var hiddenBookmarks: [String] {
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
            let schedulesPublisher = scheduleService.$schedules
            let courseColorsPublisher = courseColorService.$courseColors
            let executionStatusPublisher = scheduleService.$executionStatus
            let bookmarksPublisher = preferenceService.$bookmarks

            Publishers.CombineLatest4(schedulesPublisher, courseColorsPublisher, executionStatusPublisher, bookmarksPublisher)
                .receive(on: DispatchQueue.main)
                .sink { schedules, courseColors, executionStatus, bookmarks in
                    
                    // Update view model properties with the processed data
                    self.schedules = schedules
                    self.courseColors = courseColors
                    self.handleDataExecutionStatus(executionStatus: executionStatus)
                    self.handleNewBookmarks(newBookmarks: bookmarks)
                }
                .store(in: &cancellables)
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
            days = (filterHiddenBookmarks(
                schedules: schedules,
                hiddenBookmarks: hiddenBookmarks)
            ).flatten().toOrderedDayUiModels()
            status = .loaded
        }
    }

    
    // If schedule service is modified in app
    func handleDataExecutionStatus(executionStatus: ExecutionStatus) -> Void {
        switch executionStatus {
        case .executing:
            status = .loading
        case .error:
            status = .error
        case .available:
            guard !schedules.isEmpty else {
                status = .uninitialized
                return
            }
            let hiddenBookmarks = bookmarks?.filter { !$0.toggled }.map { $0.id } ?? []
            if filterHiddenBookmarks(schedules: schedules, hiddenBookmarks: hiddenBookmarks).isEmpty {
                status = .hiddenAll
            } else {
                status = .loaded
            }
        }
    }

    
    func createViewModelEventSheet(event: Response.Event, color: Color) -> EventDetailsSheetViewModel {
        return viewModelFactory.makeViewModelEventDetailsSheet(event: event, color: color)
    }
    
    
    func onChangeViewType(viewType: BookmarksViewType) -> Void {
        let viewTypeIndex: Int = scheduleViewTypes.firstIndex(of: viewType)!
        preferenceService.setViewType(viewType: viewTypeIndex)
        self.defaultViewType = viewType
    }
}
