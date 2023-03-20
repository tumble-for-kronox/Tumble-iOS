//
//  VerboseEventButtonLabel.swift
//  tumble-ios
//
//  Created by Adis Veletanlic on 2023-03-20.
//

import SwiftUI

struct VerboseEventButtonLabel: View {
    
    let event: Response.Event
    let color: Color
    
    var body: some View {
        HStack {
            VStack (alignment: .leading, spacing: 20) {
                VStack (alignment: .leading, spacing: 2) {
                    Text(event.course.englishName)
                        .font(.system(size: 19, weight: .semibold))
                        .foregroundColor(.onSurface)
                    Text(event.title)
                        .lineLimit(1)
                        .truncationMode(.tail)
                        .font(.system(size: 17))
                        .foregroundColor(.onSurface.opacity(0.7))
                }
                HStack {
                    Image(systemName: "person.3.sequence")
                        .font(.system(size: 17))
                        .foregroundColor(.onSurface.opacity(0.7))
                    if let teacher = event.teachers.first {
                        if !teacher.firstName.isEmpty && !teacher.lastName.isEmpty {
                            Text("\(teacher.firstName) \(teacher.lastName)")
                                .font(.system(size: 17))
                                .foregroundColor(.onSurface.opacity(0.7))
                        } else {
                            Text("No teachers listed")
                                .font(.system(size: 17))
                                .foregroundColor(.onSurface.opacity(0.7))
                        }
                    }  else {
                        Text("No teachers listed")
                            .font(.system(size: 17))
                            .foregroundColor(.onSurface.opacity(0.7))
                    }
                }
                HStack {
                    HStack {
                        Image(systemName: "mappin.and.ellipse")
                            .font(.system(size: 17))
                            .foregroundColor(.onSurface.opacity(0.7))
                        Text(event.locations.first?.id.capitalized ?? "Unknown")
                            .font(.system(size: 17))
                            .foregroundColor(.onSurface.opacity(0.7))
                    }
                    Spacer()
                    if let time = event.from.convertISOToHoursAndMinutes() {
                        HStack {
                            Circle()
                                .foregroundColor(color)
                                .frame(height: 7)
                            Text(time)
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundColor(.onSurface)
                        }
                    }
                }
            }
            .padding()
            .frame(height: 170, alignment: .leading)
            .frame(maxWidth: .infinity)
            .background(Color.surface)
            .cornerRadius(20)
            .padding([.leading, .trailing], 8)
            Spacer()
        }
    }
}

