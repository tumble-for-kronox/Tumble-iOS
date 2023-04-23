//
//  EventDetailsBodyView.swift
//  Tumble
//
//  Created by Adis Veletanlic on 2023-02-01.
//

import SwiftUI

struct EventDetailsBody: View {
    let event: Event
    
    var body: some View {
        VStack(alignment: .leading) {
            DetailsBuilder(title: NSLocalizedString("Course", comment: ""), image: "text.book.closed") {
                Text(event.course?.englishName ?? "")
                    .font(.system(size: 16))
                    .foregroundColor(.onSurface)
            }
            DetailsBuilder(title: NSLocalizedString("Teachers", comment: ""), image: "person.3.sequence") {
                if !event.teachers.isEmpty {
                    if !event.teachers.first!.firstName.isEmpty && !event.teachers.first!.lastName.isEmpty {
                        ForEach(event.teachers, id: \.self) { teacher in
                            Text("\(teacher.firstName) \(teacher.lastName)")
                                .font(.system(size: 16))
                                .foregroundColor(.onSurface)
                        }
                    } else {
                        Text(NSLocalizedString("No teachers listed at this time", comment: ""))
                            .font(.system(size: 16))
                            .foregroundColor(.onSurface)
                    }
                } else {
                    Text(NSLocalizedString("No teachers listed at this time", comment: ""))
                        .font(.system(size: 16))
                        .foregroundColor(.onSurface)
                }
            }
            DetailsBuilder(title: NSLocalizedString("Date", comment: ""), image: "calendar") {
                Text("\(event.from.formatDate() ?? "")")
                    .font(.system(size: 16))
                    .foregroundColor(.onSurface)
            }
            DetailsBuilder(title: NSLocalizedString("Time", comment: ""), image: "clock") {
                Text("\(event.from.convertToHoursAndMinutesISOString() ?? "") - \(event.to.convertToHoursAndMinutesISOString() ?? "")")
                    .font(.system(size: 16))
                    .foregroundColor(.onSurface)
            }
            DetailsBuilder(title: NSLocalizedString("Locations", comment: ""), image: "mappin.and.ellipse") {
                if event.locations.count > 0 {
                    ForEach(event.locations, id: \.self) { location in
                        Text(location.locationId.capitalized)
                            .font(.system(size: 16))
                            .foregroundColor(.onSurface)
                    }
                } else {
                    Text(NSLocalizedString("No locations listed at this time", comment: ""))
                        .font(.system(size: 16))
                        .foregroundColor(.onSurface)
                }
            }
            
            Spacer()
        }
    }
}
