//
//  EventDetailsCardView.swift
//  tumble-ios
//
//  Created by Adis Veletanlic on 2023-01-31.
//

import SwiftUI

struct EventDetailsCard: View {
    
    @ObservedObject var parentViewModel: EventDetailsSheetViewModel
    @State private var bgColor = Color.red
    
    let openColorPicker: () -> Void
    let event: Response.Event
    let color: Color
    
    var body: some View {
        VStack (alignment: .leading, spacing: 0) {
            HStack {
                VStack {
                    HStack {
                        VStack (alignment: .leading, spacing: 0) {
                            Text(event.title)
                                .font(.system(size: 28, design: .rounded))
                                .foregroundColor(color.isDarkBackground(color: color) ? .bright : .dark)
                                .padding(.bottom, 7)
                            Text(event.course.englishName)
                                .font(.system(size: 20))
                                .italic()
                                .foregroundColor(color.isDarkBackground(color: color) ? .bright : .dark)
                        }
                        .padding(.bottom, 30)
                        Spacer()
                    }
                    HStack (spacing: 7.5) {
                        if event.from.isAvailableNotificationDate() {
                            EventDetailsPill(
                                title: !parentViewModel.isNotificationSetForEvent ? "Event" : "Remove",
                                image: "bell.badge",
                                onTap: !parentViewModel.isNotificationSetForEvent ? onSetNotificationEvent : onRemoveNotificationForEvent)
                        }
                        EventDetailsPill(
                            title: !parentViewModel.isNotificationSetForCourse ? "Course" : "Remove",
                            image: "bell.badge.fill",
                            onTap: !parentViewModel.isNotificationSetForCourse ? onSetNotificationForCourse : onRemoveNotificationForCourse)
                        EventDetailsPill(title: "Color", image: "paintbrush", onTap: openColorPicker)
                        Spacer()
                    }
                }
                Spacer()
            }
        }
        .frame(minWidth: UIScreen.main.bounds.width - 60)
        .padding(10)
        .background(event.isSpecial ? LinearGradient(gradient: Gradient(colors: [.red, .red.opacity(0.7)]), startPoint: .leading, endPoint: .trailing) : LinearGradient(gradient: Gradient(colors: [color, color.opacity(0.7)]), startPoint: .leading, endPoint: .trailing))
        .cornerRadius(20)
        .padding(.all, 15)
    }
    
    func onSetNotificationEvent() -> Void {
        parentViewModel.scheduleNotificationForEvent()
    }
    
    func onSetNotificationForCourse() -> Void {
        parentViewModel.scheduleNotificationsForCourse()
    }
    
    func onRemoveNotificationForEvent() -> Void {
        parentViewModel.cancelNotificationForEvent()
    }
    
    func onRemoveNotificationForCourse() -> Void {
        parentViewModel.cancelNotificationsForCourse()
    }

}
