//
//  CompactEventButton.swift
//  tumble-ios
//
//  Created by Adis Veletanlic on 2023-03-20.
//

import SwiftUI

struct CompactEventButtonLabel: View {
    
    let event: Response.Event
    let color: Color
    
    var body: some View {
        HStack (spacing: 0) {
            if let time = event.from.convertToHoursAndMinutesISOString() {
                HStack {
                    Circle()
                        .foregroundColor(color)
                        .frame(width: 7, height: 7)
                        .padding(.trailing, 0)
                    Text(time)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.onSurface)
                }
                .frame(width: 65)
                .padding(.horizontal)
            }
            Divider()
                .foregroundColor(.onSurface)
            VStack (alignment: .leading, spacing: 10) {
                HStack {
                    Text(event.title)
                        .font(.system(size: 17, weight: .medium))
                        .foregroundColor(.onSurface)
                        .lineLimit(1)
                        .truncationMode(.tail)
                    Spacer()
                    if event.isSpecial {
                        Image(systemName: "person.crop.circle.badge.exclamationmark")
                            .font(.system(size: 15))
                            .foregroundColor(.onSurface.opacity(0.7))
                    }
                }
                HStack {
                    Image(systemName: "mappin.and.ellipse")
                        .font(.system(size: 15))
                        .foregroundColor(.onSurface.opacity(0.7))
                    Text(event.locations.first?.id.capitalized ?? "Unknown")
                        .font(.system(size: 15))
                        .foregroundColor(.onSurface.opacity(0.7))
                }
                HStack {
                    Image(systemName: "person.3.sequence")
                        .font(.system(size: 15))
                        .foregroundColor(.onSurface.opacity(0.7))
                    if let teacher = event.teachers.first {
                        if !teacher.firstName.isEmpty && !teacher.lastName.isEmpty {
                            Text("\(teacher.firstName) \(teacher.lastName)")
                                .font(.system(size: 15))
                                .foregroundColor(.onSurface.opacity(0.7))
                        } else {
                            Text("No teachers listed")
                                .font(.system(size: 15))
                                .foregroundColor(.onSurface.opacity(0.7))
                        }
                    }  else {
                        Text("No teachers listed")
                            .font(.system(size: 15))
                            .foregroundColor(.onSurface.opacity(0.7))
                    }
                }
            }
            .padding()
            Spacer()
        }
    }
}

