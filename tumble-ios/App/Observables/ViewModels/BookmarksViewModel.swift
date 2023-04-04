//
//  SchedulePageMainView-ViewModel.swift
//  tumble-ios
//
//  Created by Adis Veletanlic on 11/21/22.
//

import Foundation
import SwiftUI

@MainActor final class BookmarksViewModel: ObservableObject {
    
    let viewModelFactory: ViewModelFactory = ViewModelFactory()
    
    @Inject var scheduleService: ScheduleService
    @Inject var preferenceService: PreferenceService
    @Inject var courseColorService: CourseColorService
    @Inject var networkManager: KronoxManager
    @Inject var schoolManager: SchoolManager
    
    @Published var scheduleViewTypes: [BookmarksViewType] = BookmarksViewType.allValues
    @Published var status: BookmarksViewStatus = .loading
    @Published var scheduleListOfDays: [DayUiModel] = []
    @Published var courseColors: [String : String] = [:]
    @Published var defaultViewType: BookmarksViewType = .list
    @Published var school: School?
    @Published var eventSheet: EventDetailsSheetModel? = nil
    
    
    init () {
        self.loadBookmarkedSchedules()
        self.defaultViewType = preferenceService.getDefaultViewType()
        self.school = preferenceService.getDefaultSchoolName(schools: schoolManager.getSchools())
    }
    
    
    func generateViewModelEventSheet(event: Response.Event, color: Color) -> EventDetailsSheetViewModel {
        return viewModelFactory.makeViewModelEventDetailsSheet(event: event, color: color)
    }
    
    
    func updateViewLocals() -> Void {
        self.school = preferenceService.getDefaultSchoolName(schools: schoolManager.getSchools())
    }
    
    func updateCourseColors() -> Void {
        self.loadCourseColors() { courseColors in
            self.courseColors = courseColors
        }
    }
    
    func loadBookmarkedSchedules() {
        self.status = .loading
        self.loadSchedules { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .failure:
                AppLogger.shared.critical("Could not load schedules from local storage")
                self.status = .error
            case .success(let schedules):
                self.loadCourseColors { courseColors in
                    self.courseColors = courseColors
                    guard !schedules.isEmpty else {
                        self.status = .uninitialized
                        return
                    }
                    let visibleSchedules = self.filterHiddenBookmarks(schedules: schedules)
                    self.updateSchedulesIfNeeded(schedules: visibleSchedules) {
                        self.updateViewStatus(schedules: visibleSchedules)
                    }
                }
            }
        }
    }

    private func loadSchedules(completion: @escaping (Result<[ScheduleStoreModel], Error>) -> Void) {
        self.scheduleService.load(completion: {result in
            completion(result)
        })
    }

    fileprivate func filterHiddenBookmarks(schedules: [ScheduleStoreModel]) -> [ScheduleStoreModel] {
        let hiddenBookmarks = self.preferenceService.getHiddenBookmarks()
        return schedules.filter { schedule in
            !hiddenBookmarks.contains { $0 == schedule.id }
        }
    }


    private func updateSchedulesIfNeeded(schedules: [ScheduleStoreModel], completion: @escaping () -> Void) {
        updateSchedules(for: schedules, completion: completion)
    }

    private func updateViewStatus(schedules: [ScheduleStoreModel]) {
        DispatchQueue.main.async {
            if schedules.isEmpty {
                self.status = .hiddenAll
            } else {
                self.status = .loaded
            }
        }
    }

    
    
    func onChangeViewType(viewType: BookmarksViewType) -> Void {
        let viewTypeIndex: Int = scheduleViewTypes.firstIndex(of: viewType)!
        preferenceService.setViewType(viewType: viewTypeIndex)
    }
}
