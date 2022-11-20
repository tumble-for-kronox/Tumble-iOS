//
//  ScheduleCardview.swift
//  tumble-ios
//
//  Created by Adis Veletanlic on 11/18/22.
//

import SwiftUI

struct ScheduleCardView: View {
    let event: API.Types.Response.Event
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 10)
                .fill(Color.red)
                .shadow(radius: 2.5)
            Rectangle()
                .fill(.white)
                .offset(x: 10)
                .cornerRadius(10, corners: [.topRight, .bottomRight])
            VStack (alignment: .leading, spacing: 0) {
                HStack {
                    Circle()
                        .foregroundColor(Color.red)
                        .frame(height: 7)
                    Text("\(event.from.ISOtoHours()) - \(event.to.ISOtoHours())")
                        .font(.subheadline)
                        .foregroundColor(.black.opacity(0.75))
                    Spacer()
                }
                .padding(.top, 20)
                .padding(.leading, 25)
                .padding(.bottom, 10)
                VStack (alignment: .leading) {
                    Text(event.title)
                        .font(.title2)
                        .bold()
                        .padding(.leading, 25)
                        .padding(.trailing, 25)
                        .padding(.bottom, 2.5)
                    VStack {
                        Text(event.course.englishName.trimmingCharacters(in: .whitespaces))
                            .font(.title3)
                            .padding(.leading, 25)
                            .padding(.bottom, 10)
                        Spacer()
                    }
                    Spacer()
                }
                Spacer()
            }
            
        }
        .frame(height: 155)
        .padding(.leading, 20)
        .padding(.trailing, 20)
        .padding(.bottom, 15)
        .padding(.top, 15)
    }
}

extension View {
    func cornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
        clipShape( RoundedCorner(radius: radius, corners: corners) )
    }
}

struct RoundedCorner: Shape {

   var radius: CGFloat = .infinity
   var corners: UIRectCorner = .allCorners

   func path(in rect: CGRect) -> Path {
       let path = UIBezierPath(roundedRect: rect, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
       return Path(path.cgPath)
   }
}
