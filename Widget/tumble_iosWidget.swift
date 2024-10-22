import SwiftUI
import WidgetKit
import RealmSwift

struct tumble_iosWidget: Widget {
    let kind: String = "tumble_widget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            VStack {
                if let event = entry.event {
                    WidgetView(event: event)
                        .widgetURL(URL(string: event.eventId))
                } else {
                    Text(NSLocalizedString("No upcoming events available", comment: ""))
                }
            }
            .widgetBackground(Color.surface)
        }
        .configurationDisplayName("Upcoming event")
        .description("Shows the earliest upcoming event.")
        .supportedFamilies(getSupportedFamilies())
    }
    
    /// Helper function to handle supported families
    private func getSupportedFamilies() -> [WidgetFamily] {
        if #available(iOSApplicationExtension 16.0, *) {
            return [.systemSmall, .systemMedium, .accessoryRectangular, .accessoryInline]
        } else {
            return [.systemSmall, .systemMedium]
        }
    }
}
