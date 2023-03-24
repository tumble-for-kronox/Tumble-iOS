//
//  EventDetailsBodyView.swift
//  tumble-ios
//
//  Created by Adis Veletanlic on 2023-02-01.
//

import SwiftUI

struct EventDetailsBody: View {
    
    let event: Response.Event
    
    var body: some View {
        VStack (alignment: .leading) {
            VStack  {
                DetailsBuilder(title: "Course", image: "text.book.closed") {
                    Text(event.course.englishName)
                }
                DetailsBuilder(title: "Teachers", image: "person.3.sequence") {
                    if !event.teachers.isEmpty {
                        if !event.teachers.first!.firstName.isEmpty && !event.teachers.first!.lastName.isEmpty {
                            ForEach(event.teachers, id: \.self) { teacher in
                                Text("\(teacher.firstName) \(teacher.lastName)")
                                    .font(.system(size: 18))
                                    .foregroundColor(.onSurface)
                            }
                        } else {
                            Text("No teachers listed at this time")
                                .font(.system(size: 18))
                                .foregroundColor(.onSurface)
                        }
                    } else {
                        Text("No teachers listed at this time")
                            .font(.system(size: 18))
                            .foregroundColor(.onSurface)
                    }
                }
                DetailsBuilder(title: "Date", image: "calendar") {
                    Text("\(event.from.formatDate() ?? "")")
                        .font(.system(size: 18))
                        .foregroundColor(.onSurface)
                }
                DetailsBuilder(title: "Time", image: "clock") {
                    Text("\(event.from.convertToHoursAndMinutesISOString() ?? "") - \(event.to.convertToHoursAndMinutesISOString() ?? "")")
                        .font(.system(size: 18))
                        .foregroundColor(.onSurface)
                }
                DetailsBuilder(title: "Locations", image: "mappin.and.ellipse") {
                    if event.locations.count > 0 {
                        ForEach(event.locations, id: \.self) { location in
                            Text(location.id.capitalized)
                                .font(.system(size: 18))
                                .foregroundColor(.onSurface)
                        }
                    } else {
                        Text("No locations listed at this time")
                            .font(.system(size: 18))
                            .foregroundColor(.onSurface)
                    }
                }
                
                Spacer()
            }
            
        }
    }
}

