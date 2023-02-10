//
//  EventDetailsCardView.swift
//  tumble-ios
//
//  Created by Adis Veletanlic on 2023-01-31.
//

import SwiftUI

struct EventDetailsCard: View {
    
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var parentViewModel: EventDetailsSheet.EventDetailsSheetViewModel
    @State private var bgColor = Color.red
    
    let createToast: (ToastStyle, String, String) -> Void
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
                        if !parentViewModel.isNotificationSetForEvent {
                            EventDetailsPill(title: "Event", image: "bell.badge", onTap: onSetNotificationEvent)
                            
                        } else {
                            EventDetailsPill(title: "Remove", image: "bell.badge", onTap: onRemoveNotificationForEvent)
                        }
                        if !parentViewModel.isNotificationSetForCourse {
                            EventDetailsPill(title: "Course", image: "bell.badge.fill", onTap: onSetNotificationForCourse)
                        } else {
                            EventDetailsPill(title: "Remove", image: "bell.badge.fill", onTap: onRemoveNotification)
                        }
                        
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
        parentViewModel.scheduleNotificationForEvent() { success in
            if success {
                createToast(.success, "Notification set!", "Notification was created for \(event.title)")
            } else {
                createToast(.error, "Notification not set!", "Looks like you need to allow notifications in your phone settings")
            }
        }
        DispatchQueue.main.async {
            dismiss()
        }
    }
    
    func onSetNotificationForCourse() -> Void {
        parentViewModel.scheduleNotificationsForCourse() { success in
            if success {
                createToast(.success, "Notifications set!", "Notifications were created for available events in \(event.course.englishName)")
            } else {
                createToast(.error, "Notifications not set!", "Looks like you need to allow notifications in your phone settings")
            }
        }
        DispatchQueue.main.async {
            dismiss()
        }
    }
    
    func onRemoveNotificationForEvent() -> Void {
        parentViewModel.cancelNotificationForEvent()
        dismiss()
        createToast(.success, "Notification removed!", "Notification for \(event.title) was removed")
    }
    
    func onRemoveNotification() -> Void {
        parentViewModel.cancelNotificationsForCourse()
        dismiss()
        createToast(.success, "Notifications removed!", "Notifications for \(event.course.englishName) were removed")
    }

}
