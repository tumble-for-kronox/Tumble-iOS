//
//  EventDetailsBodyView.swift
//  Tumble
//
//  Created by Adis Veletanlic on 2023-02-01.
//

import SwiftUI
import RealmSwift

struct EventDetailsBody: View {
    let event: Event
    
    @State private var locationSheetOpen = false
    
    var body: some View {
        VStack(alignment: .leading) {
            DetailsBuilder(title: NSLocalizedString("Course", comment: ""), image: "text.book.closed") {
                Text(event.course?.englishName ?? "")
                    .font(.system(size: 16))
                    .foregroundColor(.onSurface)
            }
            DetailsBuilder(title: NSLocalizedString("Teachers", comment: ""), image: "person.2") {
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
                    HStack {
                        VStack {
                            ForEach(event.locations, id: \.self) { location in
                                Text(location.locationId.capitalized)
                                    .font(.system(size: 16))
                                    .foregroundColor(.onSurface)
                            }
                        }
                        Spacer()
                        Image(systemName: "chevron.right")
                            .foregroundColor(.onSurface.opacity(0.4))
                            .font(.system(size: 14, weight: .semibold))
                    }
                } else {
                    Text(NSLocalizedString("No locations listed at this time", comment: ""))
                        .font(.system(size: 16))
                        .foregroundColor(.onSurface)
                }
            }
            .onTapGesture {
                if !event.locations.isEmpty {
                    locationSheetOpen = true
                    HapticsController.triggerHapticLight()
                }
            }
            .sheet(isPresented: $locationSheetOpen, content: {
                EventLocationsView(event: event)
            })
            
            Spacer()
        }
    }
}

#Preview {
    let locations = [Location(
        locationId: "a-421",
        name: "",
        building: "",
        floor: "",
        maxSeats: 0
    ), Location(
        locationId: "e-421",
        name: "",
        building: "",
        floor: "",
        maxSeats: 0
    )]
    var realmLocations = RealmSwift.List<Location>()
    realmLocations.append(objectsIn: locations)
    
    let teachers = [Teacher(
        teacherId: "1",
        firstName: "Kamilla",
        lastName: "Klonowska"
    )]
    var realmTeachers = RealmSwift.List<Teacher>()
    realmTeachers.append(objectsIn: teachers)
    
    let event = Event(
        eventId: "1",
        title: "Event title",
        course: Course(
            courseId: "1",
            swedishName: "Kurs",
            englishName: "Introduction to Computer Science",
            color: "FF00FF"
        ),
        from: "12:00",
        to: "13:15",
        locations: realmLocations,
        teachers: realmTeachers,
        isSpecial: false,
        lastModified: "12-12-1211",
        schoolId: "3"
    )
    
    return EventDetailsBody(event: event)

}
