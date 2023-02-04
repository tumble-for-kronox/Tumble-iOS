//
//  SchedulePageMainView-ViewModel.swift
//  tumble-ios
//
//  Created by Adis Veletanlic on 11/21/22.
//

import Foundation
import SwiftUI

enum BookmarksViewType: String {
    case list = "List"
    case calendar = "Calendar"
    
    static let allValues: [BookmarksViewType] = [list, calendar]
}

enum BookmarksViewStatus {
    case loading
    case loaded
    case uninitialized
    case error
}

extension BookmarksView {
    @MainActor final class BookmarksViewModel: ObservableObject {
        
        @Inject var scheduleService: ScheduleService
        @Inject var preferenceService: PreferenceService
        @Inject var courseColorService: CourseColorService
        
        @Published var scheduleViewTypes: [BookmarksViewType] = BookmarksViewType.allValues
        @Published var status: BookmarksViewStatus = .loading
        @Published var days: [DayUiModel] = []
        @Published var courseColors: CourseAndColorDict = [:]
        @Published var defaultViewType: BookmarksViewType
        
        init () {
            self.defaultViewType = .list
            self.loadSchedules()
            self.defaultViewType = preferenceService.getDefaultViewType()
        }
        
        func loadSchedules() -> Void {
            scheduleService.load { [weak self] result in
                switch result {
                case .failure(_):
                    self?.status =  .error
                case .success(let schedules):
                    if !schedules.isEmpty {
                        let days: [DayUiModel] = schedules.removeDuplicateEvents().flatten()
                        self?.days = days
                        self?.status = .loaded
                        self?.loadCourseColors()
                    }
                    else {
                        self?.status = .uninitialized
                    }
                }
            }
        }
        
        func onChangeViewType(viewType: BookmarksViewType) -> Void {
            let viewTypeIndex: Int = scheduleViewTypes.firstIndex(of: viewType)!
            preferenceService.setViewType(viewType: viewTypeIndex)
        }
        
        fileprivate func loadCourseColors() -> Void {
            courseColorService.load { [weak self] result in
                switch result {
                case .failure(_):
                    // TODO: Add user notification toast that something went wrong
                    AppLogger.shared.info("Could not load course colors")
                case .success(let courses):
                    if !courses.isEmpty {
                        self?.courseColors = courses
                    }
                }
            }
        }
    }
}
