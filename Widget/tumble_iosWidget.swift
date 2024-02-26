import WidgetKit
import SwiftUI
import RealmSwift

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

struct EventEntry: TimelineEntry {
    let date: Date
    let event: Event?
}

struct tumble_widgetEntryView: View {
    @Environment(\.widgetFamily) var family
    var entry: Provider.Entry

    var body: some View {
        ZStack {
            if let event = entry.event {
                WidgetView(family: family, event: event)
            } else {
                Text("No upcoming events")
            }
        }
        .widgetBackground(Color.surface)
    }
}

struct tumble_iosWidget: Widget {
    let kind: String = "tumble_widget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            tumble_widgetEntryView(entry: entry)
        }
        .configurationDisplayName("Upcoming event")
        .description("Shows the earliest upcoming event.")
        .supportedFamilies([.systemSmall, .systemMedium])
    }
}

struct tumble_widget_Previews: PreviewProvider {
    static var previews: some View {
        tumble_widgetEntryView(entry: EventEntry(date: Date(), event: Event(
            eventId: "BokningsId_20230627_000000085",
            title: "DA381A, Test 2 Big data – theory. Written Re-re-exam",
            course: Course(
                courseId: "DA381A 2023 45 50 DAG NML en-",
                swedishName: "Analys av stora datamängder",
                englishName: "Analys av stora datamängder",
                color: "#8B0000"
            ),
            from: "2024-06-14T07:00:00Z",
            to: "2024-06-14T12:00:00Z",
            locations: RealmSwift.List<Location>(),
            teachers: RealmSwift.List<Teacher>(),
            isSpecial: true,
            lastModified: "2024-01-30T10:14:04Z"
        )))
            .previewContext(WidgetPreviewContext(family: .systemMedium))
    }
}

extension View {
    func widgetBackground(_ backgroundView: some View) -> some View {
        if #available(iOSApplicationExtension 17.0, *) {
            return containerBackground(for: .widget) {
                backgroundView
            }
        } else {
            return background(backgroundView)
        }
    }
}
