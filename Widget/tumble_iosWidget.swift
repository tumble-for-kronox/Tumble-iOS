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
                } else {
                    Text(NSLocalizedString("No upcoming events available", comment: ""))
                }
            }
            .widgetBackground(Color.surface)
        }
        .configurationDisplayName("Upcoming event")
        .description("Shows the earliest upcoming event.")
        .supportedFamilies([.systemSmall, .systemMedium])
    }
}
