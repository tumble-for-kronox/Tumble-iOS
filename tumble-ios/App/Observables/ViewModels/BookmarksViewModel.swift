//
//  SchedulePageMainView-ViewModel.swift
//  tumble-ios
//
//  Created by Adis Veletanlic on 11/21/22.
//

import Foundation
import SwiftUI
import Combine

@MainActor final class BookmarksViewModel: ObservableObject {
    
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
    
    init () {
        initialisePipelines()
        defaultViewType = preferenceService.getDefaultViewType()
    }
    
    func initialisePipelines() -> Void {
        // Set up publisher to update schedules when data stores are updated
        scheduleService.$schedules
            .assign(to: \.schedules, on: self)
            .store(in: &cancellables)
        courseColorService.$courseColors
            .assign(to: \.courseColors, on: self)
            .store(in: &cancellables)
        scheduleService.$executionStatus
            .sink { [weak self] executionStatus in
                guard let self else { return }
                self.handleDataExecutionStatus(executionStatus: executionStatus)
            }
            .store(in: &cancellables)
        preferenceService.$bookmarks
            .sink { [weak self] newBookmarks in
                guard let self else { return }
                self.handleNewBookmarks(newBookmarks: newBookmarks)
            }
            .store(in: &cancellables)
    }
    
    // If bookmarks in preferences are modified in app
    func handleNewBookmarks(newBookmarks: [Bookmark]?) -> Void {
        self.status = .loading
        self.bookmarks = newBookmarks
        // Always update view of days
        defer {
            let hiddenBookmarks = newBookmarks?.filter { !$0.toggled } ?? []
            days = (filterHiddenBookmarks(
                schedules: schedules,
                hiddenBookmarks: hiddenBookmarks.map { $0.id })
            ).flatten().toOrderedDayUiModels()
        }
        if let newBookmarks = newBookmarks {
            if newBookmarks.isEmpty {
                self.status = .uninitialized
                return
            }
            // If new bookmarks where toggled value is true is empty,
            // the user has hidden all their schedules
            if (newBookmarks.filter { $0.toggled }).isEmpty {
                self.status = .hiddenAll
            } else {
                self.status = .loaded
            }
        } else {
            self.status = .uninitialized
        }
    }
    
    // If schedule service is modified in app
    func handleDataExecutionStatus(executionStatus: ExecutionStatus) -> Void {
        DispatchQueue.main.async { [weak self] in
            guard let self else { return }
            switch executionStatus {
            case .executing:
                self.status = .loading
            case .error:
                self.status = .error
            case .available:
                if schedules.isEmpty {
                    self.status = .uninitialized
                } else {
                    let hiddenBookmarks = bookmarks?.filter { !$0.toggled }.map { $0.id } ?? []
                    if filterHiddenBookmarks(schedules: schedules, hiddenBookmarks: hiddenBookmarks).isEmpty {
                        self.status = .hiddenAll
                    } else {
                        self.status = .loaded
                    }
                }
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
