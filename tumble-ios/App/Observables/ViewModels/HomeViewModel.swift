//
//  HomeViewModel.swift
//  tumble-ios
//
//  Created by Adis Veletanlic on 11/20/22.
//

import Foundation
import SwiftUI
import Combine
import RealmSwift

final class HomeViewModel: ObservableObject {
    
    @Inject var preferenceService: PreferenceService
    @Inject var userController: UserController
    @Inject var kronoxManager: KronoxManager
    
    @Published var newsSectionStatus: GenericPageStatus = .loading
    @Published var news: Response.NewsItems? = nil
    @Published var swipedCards: Int = 0
    @Published var status: HomeStatus = .loading
    @Published var eventsForToday: [WeekEventCardModel] = []
    @Published var nextClass: Event? = nil
    @Published var bookmarks: [Bookmark]?
    @ObservedResults(Schedule.self) var schedules
    
    private let viewModelFactory: ViewModelFactory = ViewModelFactory.shared
    private var cancellables = Set<AnyCancellable>()
    private var hiddenBookmarks: [String] {
        return bookmarks?.filter { !$0.toggled }.map { $0.id } ?? []
    }
    
    init() {
        setUpDataPublishers()
        getNews()
    }
    
    func setUpDataPublishers() -> Void {
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            guard let self else { return }
            let bookmarksPublisher = self.preferenceService.$bookmarks
            bookmarksPublisher
                .receive(on: DispatchQueue.main)
                .sink { bookmarks in
                    self.bookmarks = bookmarks
                }
                .store(in: &self.cancellables)
        }
    }
    
    func getNews() -> Void {
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
    
    func createDayCards(events: [Event]) -> [WeekEventCardModel] {
        let weekEventCards = events.map {
            return WeekEventCardModel(event: $0)
        }
        return weekEventCards.reversed()
    }
    
    func findNextUpcomingEvent(schedules: [Schedule]) -> Event? {
        let hiddenBookmarks = bookmarks?.filter { !$0.toggled }.map { $0.id } ?? []
        let days: [Day] = schedules.filter {!hiddenBookmarks.contains($0.scheduleId)}.flatMap { $0.days }
        let events: [Event] = days.flatMap { $0.events }
        let sortedEvents = events.sorted()
        let now = Date()
        
        // Find the most recent upcoming event that is not today
        if let nextEvent = sortedEvents.first(where: { isoDateFormatter.date(from: $0.from)! > now }) {
            if Calendar.current.isDate(now, inSameDayAs: isoDateFormatter.date(from: nextEvent.from)!) {
                // If the next event is today, find the next upcoming event that is not today
                if let nextNonTodayEvent = sortedEvents.first(where: {
                    !Calendar.current.isDate(now, inSameDayAs: isoDateFormatter.date(from: $0.from)!) &&
                    isoDateFormatter.date(from: $0.from)! > now
                }) {
                    return nextNonTodayEvent
                } else {
                    return nil
                }
            } else {
                return nextEvent
            }
        }
        return nil
    }
    
}
