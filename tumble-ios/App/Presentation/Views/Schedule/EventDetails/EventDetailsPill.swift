//
//  EventDetailsPill.swift
//  tumble-ios
//
//  Created by Adis Veletanlic on 2023-02-01.
//

import SwiftUI

struct EventDetailsPill: View {
    let event: Response.Event
    let title: String
    let image: String
    var body: some View {
        HStack {
            Image(systemName: image)
                .font(.system(size: 14))
            Text(title)
                .font(.system(size: 15, design: .rounded))
        }
        .padding(.all, 10)
        .background(Color.surface)
        .cornerRadius(20)
        
    }
}

struct EventDetailsPill_Previews: PreviewProvider {
    static var previews: some View {
        EventDetailsPill(event: Response.Event(title: "Lecture 1 - React Native", course: Response.Course(id: "courseID", swedishName: "Frontend Utveckling", englishName: "Frontend Development"), from: "10:15", to: "12:00", locations: [Response.Location(id: "locationID", name: "", building: "14-327", floor: "3", maxSeats: 100)], teachers: [Response.Teacher(id: "teacherID", firstName: "Thomas", lastName: "Frank")], id: "teachersId", isSpecial: false, lastModified: ""), title: "Notification", image: "bell")
    }
}
