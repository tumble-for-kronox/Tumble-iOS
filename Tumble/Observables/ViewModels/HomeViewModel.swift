//
//  HomeViewModel.swift
//  Tumble
//
//  Created by Adis Veletanlic on 11/20/22.
//

import Combine
import Foundation
import RealmSwift
import SwiftUI

final class HomeViewModel: ObservableObject {
    @Inject var kronoxManager: KronoxManager
    @Inject var realmManager: RealmManager
    
    @Published var newsSectionStatus: GenericPageStatus = .loading
    @Published var news: Response.NewsItems? = nil
    @Published var swipedCards: Int = 0
    @Published var status: HomeStatus = .loading
    @Published var todaysEventsCards: [DayEventCardModel] = .init()
    @Published var nextClass: Event? = nil
    
    private let viewModelFactory: ViewModelFactory = .shared
    private var schedulesToken: NotificationToken?
    
    init() {
        fetchNews()
        setupRealmListener()
    }
    
    private func setupRealmListener() {
        let schedules = realmManager.getAllLiveSchedules()
        schedulesToken = schedules.observe { [weak self] changes in
            guard let self = self else { return }
            switch changes {
            case .initial(let results), .update(let results, _, _, _):
                self.filterInitialState(results: Array(schedules))
                if self.status == .loading {
                    self.createEventCardsForToday(schedules: Array(results))
                    self.findNextUpcomingEvent(schedules: Array(results))
                }
            case .error:
                self.status = .error
            }
        }
    }
    
    private func filterInitialState(results: [Schedule]) {
        DispatchQueue.main.async { [weak self] in
            if results.isEmpty {
                self?.status = .noBookmarks
                return
            }
            if results.filter({ $0.toggled }).isEmpty {
                self?.status = .notAvailable
            }
        }
    }
    
    private func fetchNews() {
        newsSectionStatus = .loading
        let _ = kronoxManager.get(.news) { [weak self] (result: Result<Response.NewsItems, Response.ErrorMessage>) in
            guard let self = self else { return }
            switch result {
            case .success(let news):
                self.news = news
                self.newsSectionStatus = .loaded
            case .failure(let failure):
                AppLogger.shared.critical("Failed to retrieve news items: \(failure)")
                self.newsSectionStatus = .error
            }
        }
    }
    
    /// Finds the next upcoming event in all schedules
    private func findNextUpcomingEvent(schedules: [Schedule]) {
        
        let nextUpcomingEvent = schedules.findNextUpcomingEvent()
        
        DispatchQueue.main.async { [weak self] in
            self?.nextClass = nextUpcomingEvent
            self?.status = .available
        }
    }

    /// Creates and assigns a list of `DayEventCardModel`
    /// that will be displayd on the home screen
    private func createEventCardsForToday(schedules: [Schedule]) {
        DispatchQueue.main.async { [weak self] in
            self?.status = .loading
        }
        let eventsForToday = schedules.filterEventsMatchingToday()
        
        let todaysEventsCards = eventsForToday.map {
            DayEventCardModel(event: $0)
        }
        DispatchQueue.main.async { [weak self] in
            self?.todaysEventsCards = todaysEventsCards
            self?.status = .available
        }
    }
    
}