//
//  SmallEvent.swift
//  WidgetExtension
//
//  Created by Adis Veletanlic on 2/26/24.
//

import SwiftUI
import RealmSwift
import WidgetKit

struct SmallEvent: View {
    let event: Event
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 10) {
                VStack(alignment: .leading) {
                    Text(event.title)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.onSurface)
                        .lineLimit(4)
                }
                Spacer()
                if let timeFrom = event.from.convertToHoursAndMinutesISOString(),
                   let timeTo = event.to.convertToHoursAndMinutesISOString()
                {
                    HStack {
                        Image(systemName: "mappin.and.ellipse")
                            .font(.system(size: 12))
                            .foregroundColor(.onSurface)
                        Text(event.locations.first?.locationId.capitalized ?? NSLocalizedString("Unknown", comment: ""))
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundColor(.onSurface)
                    }
                    HStack {
                        Circle()
                            .foregroundColor(event.isSpecial ? Color.red : event.course?.color.toColor())
                            .frame(width: 7, height: 7)
                        HStack {
                            Text("\(timeFrom)")
                                .font(.system(size: 12, weight: .semibold))
                                .foregroundColor(.onSurface)
                            Image(systemName: "arrow.right")
                                .font(.system(size: 8, weight: .semibold))
                                .foregroundColor(.onSurface)
                            Text("\(timeTo)")
                                .font(.system(size: 12, weight: .semibold))
                                .foregroundColor(.onSurface)
                        }
                        }
                    }
            }
            Spacer()
        }
        .frame(alignment: .leading)
        .frame(maxWidth: .infinity)
        .background(Color.surface)
    }
}

struct SmallEvent_Previews: PreviewProvider {
    static var previews: some View {
        SmallEvent(event: Event(
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
        ))
        .previewContext(WidgetPreviewContext(family: .systemSmall))
        .widgetBackground(Color.surface)
    }
}
