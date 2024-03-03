//
//  Medium.swift
//  WidgetExtension
//
//  Created by Adis Veletanlic on 2/26/24.
//

import SwiftUI
import RealmSwift
import WidgetKit

struct MediumEvent: View {
    let event: Event
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 10) {
                VStack(alignment: .leading, spacing: 2) {
                    Text(event.title)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.onSurface)
                        .lineLimit(2)
                        .fixedSize(horizontal: false, vertical: true)
                    Text(event.course?.englishName ?? "")
                        .lineLimit(1)
                        .truncationMode(.tail)
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(.onSurface.opacity(0.7))
                }
                Spacer()
                VStack (alignment: .leading) {
                    HStack {
                        HStack {
                            Image(systemName: "person.2")
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundColor(.onSurface.opacity(0.7))
                            if let teacher = event.teachers.first {
                                if !teacher.firstName.isEmpty && !teacher.lastName.isEmpty {
                                    Text("\(teacher.firstName) \(teacher.lastName)")
                                        .font(.system(size: 14, weight: .semibold))
                                        .foregroundColor(.onSurface.opacity(0.7))
                                } else {
                                    Text(NSLocalizedString("No teachers listed", comment: ""))
                                        .font(.system(size: 14, weight: .semibold))
                                        .foregroundColor(.onSurface.opacity(0.7))
                                }
                            } else {
                                Text(NSLocalizedString("No teachers listed", comment: ""))
                                    .font(.system(size: 14, weight: .semibold))
                                    .foregroundColor(.onSurface.opacity(0.7))
                            }
                        }
                    Spacer()
                    if let date = dateFormatterEvent.date(from: event.from) {
                        HStack {
                            Image(systemName: "calendar")
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundColor(.onSurface.opacity(0.7))
                            Text(dateFormatterSemi.string(from: date))
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundColor(.onSurface.opacity(0.7))
                            }
                        }
                    }
                    HStack {
                        HStack {
                            Image(systemName: "mappin.and.ellipse")
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundColor(.onSurface)
                            Text(event.locations.first?.locationId.capitalized ?? NSLocalizedString("Unknown", comment: ""))
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundColor(.onSurface)
                        }
                        Spacer()
                        if let timeFrom = event.from.convertToHoursAndMinutesISOString(),
                           let timeTo = event.to.convertToHoursAndMinutesISOString()
                        {
                            HStack {
                                Circle()
                                    .foregroundColor(event.isSpecial ? Color.red : event.course?.color.toColor())
                                    .frame(width: 7, height: 7)
                                HStack {
                                    Text("\(timeFrom)")
                                        .font(.system(size: 14, weight: .semibold))
                                        .foregroundColor(.onSurface)
                                    Image(systemName: "arrow.right")
                                        .font(.system(size: 10, weight: .semibold))
                                        .foregroundColor(.onSurface)
                                    Text("\(timeTo)")
                                        .font(.system(size: 14, weight: .semibold))
                                        .foregroundColor(.onSurface)
                                }
                            }
                        }
                    }
                }
            }
            .frame(alignment: .leading)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 10)
        }
    }
}

struct MediumEvent_Previews: PreviewProvider {
    static var previews: some View {
        MediumEvent(event: Event(
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
        .previewContext(WidgetPreviewContext(family: .systemMedium))
    }
}
