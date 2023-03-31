//
//  NotificationOffsetSettings.swift
//  tumble-ios
//
//  Created by Adis Veletanlic on 3/30/23.
//

import SwiftUI

enum NotificationOffset: Int, Identifiable {
    
    var id: UUID {
        return UUID()
    }
    
    case fifteen = 15
    case thirty = 30
    case hour = 60
    case threeHours = 180
    
    static var allCases = [fifteen, thirty, hour, threeHours]
}

struct NotificationOffsetSettings: View {
    
    @Binding var offset: Int
    let rescheduleNotifications: (Int, Int) -> Void
    
    var body: some View {
        List {
            Section {
                ForEach(NotificationOffset.allCases) { type in
                    SettingsRadioButton(
                        title: getOffsetDisplayName(offset: type),
                        isSelected: Binding<Bool>(
                            get: { offset == type.rawValue },
                            set: { selected in
                                if selected {
                                    let previousOffset = offset
                                    offset = type.rawValue
                                    rescheduleNotifications(previousOffset, offset)
                                }
                            }
                        )
                    )
                }
            }
        }
    }
    
    func getOffsetDisplayName(offset: NotificationOffset) -> String {
        let minutes = offset.rawValue
        if minutes < 60 {
            return "\(minutes) \(NSLocalizedString("minutes", comment: ""))"
        } else {
            let hours = minutes / 60
            if hours == 1 {
                return "\(hours) \(NSLocalizedString("hour", comment: ""))"
            } else {
                return "\(hours) \(NSLocalizedString("hours", comment: ""))"
            }
        }
    }
    
}
