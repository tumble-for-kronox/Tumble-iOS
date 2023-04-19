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
    
    @Published var defaultViewType: BookmarksViewType = .list
    @Published var eventSheet: EventDetailsSheetModel? = nil
    @Published var days: [Day] = [Day]()
    @Published var status: BookmarksViewStatus = .loading
    
    var schedulesToken: NotificationToken? = nil
    
    init () {
        defaultViewType = preferenceService.getDefaultViewType()
        // Observe changes to schedules and update days
        let realm = try! Realm()
        let schedules = realm.objects(Schedule.self)
        schedulesToken = schedules.observe { [weak self] changes in
            guard let self = self else { return }
            switch changes {
            case .initial(let results), .update(let results, _, _, _):
                self.createDays(schedules: Array(results))
            case .error:
                self.status = .error
            }
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
    
    func createDays(schedules: [Schedule]) -> Void {
        let hiddenSchedules = Array(schedules).filter { !$0.toggled }.map { $0.scheduleId }
        let days = filterHiddenBookmarks(
            schedules: Array(schedules),
            hiddenBookmarks: hiddenSchedules)
        .flattenAndMerge().ordered()
        self.days = days
        self.status = .loaded
    }
}