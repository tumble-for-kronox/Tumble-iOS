//
//  EventDetailsCardView.swift
//  Tumble
//
//  Created by Adis Veletanlic on 2023-01-31.
//

import RealmSwift
import SwiftUI

struct EventDetailsCard: View {
    @ObservedObject var parentViewModel: EventDetailsSheetViewModel
    
    let openColorPicker: () -> Void
    let event: Event
    let color: Color
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack {
                VStack(alignment: .leading) {
                    HStack {
                        VStack(alignment: .leading, spacing: 0) {
                            Text(event.course?.englishName ?? "")
                                .font(.system(size: 20, weight: .semibold))
                                .foregroundColor(.onSurface)
                                .fixedSize(horizontal: false, vertical: true)
                                .padding(.bottom, 7)
                            Text(event.title)
                                .font(.system(size: 18))
                                .foregroundColor(.onSurface)
                        }
                        .padding(.bottom, 20)
                    }
                    VStack(alignment: .leading) {
                        HStack(spacing: 5) {
                            if parentViewModel.notificationsAllowed {
                                if event.from.isAvailableNotificationDate() {
                                    EventDetailsPill(
                                        title: !parentViewModel.isNotificationSetForEvent ?
                                            NSLocalizedString("Event", comment: "") : NSLocalizedString("Remove", comment: ""),
                                        image: "bell.badge",
                                        onTap: !parentViewModel.isNotificationSetForEvent ? onSetNotificationEvent : onRemoveNotificationForEvent
                                    )
                                }
                                EventDetailsPill(
                                    title: !parentViewModel.isNotificationSetForCourse ?
                                        NSLocalizedString("Course", comment: "") : NSLocalizedString("Remove", comment: ""),
                                    image: "bell.badge.fill",
                                    onTap: !parentViewModel.isNotificationSetForCourse ? onSetNotificationForCourse : onRemoveNotificationForCourse
                                )
                            }
                            EventDetailsPill(title: NSLocalizedString("Color", comment: ""), image: "paintbrush", onTap: openColorPicker)
                        }
                    }
                }
                Spacer()
            }
        }
        .padding(10)
        .background(event.isSpecial ? Color.red.opacity(0.2) : color.opacity(0.2))
        .cornerRadius(20)
        .padding([.horizontal, .bottom], 15)
    }
    
    func onSetNotificationEvent() {
        parentViewModel.scheduleNotificationForEvent()
    }
    
    func onSetNotificationForCourse() {
        parentViewModel.scheduleNotificationsForCourse()
    }
    
    func onRemoveNotificationForEvent() {
        parentViewModel.cancelNotificationForEvent()
    }
    
    func onRemoveNotificationForCourse() {
        parentViewModel.cancelNotificationsForCourse()
    }
}
