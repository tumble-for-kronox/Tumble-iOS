//
//  Provider.swift
//  WidgetExtension
//
//  Created by Adis Veletanlic on 2/26/24.
//

import Foundation
import WidgetKit

struct Provider: TimelineProvider {
    func placeholder(in context: Context) -> EventEntry {
        EventEntry(date: Date(), event: nil)
    }

    func getSnapshot(in context: Context, completion: @escaping (EventEntry) -> Void) {
        let entry = EventEntry(date: Date(), event: fetchEarliestEvent())
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<EventEntry>) -> Void) {
        let entry = EventEntry(date: Date(), event: fetchEarliestEvent())
        let timeline = Timeline(entries: [entry], policy: .atEnd)
        completion(timeline)
    }
    
    private func fetchEarliestEvent() -> Event? {
        let realmManager = RealmManager()
        let schedules = realmManager.getAllSchedules().filter { $0.toggled }
        let allEvents = schedules.flatMap { $0.days.flatMap { $0.events } }
        let dateFormatter = dateFormatterEvent
        
        return allEvents.min(by: { (event1, event2) -> Bool in
            guard let date1 = dateFormatter.date(from: event1.from),
                  let date2 = dateFormatter.date(from: event2.from) else {
                return false
            }
            return date1 < date2
        })
    }
}
