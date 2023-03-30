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
    
    var body: some View {
        List {
            Section {
                ForEach(NotificationOffset.allCases) { type in
                    let title = type.rawValue / 60 < 1 ? "\(type.rawValue % 60) minutes" : "\(type.rawValue / 60) hour(s)"
                    SettingsRadioButton(
                        title: title,
                        onToggle: {},
                        isSelected: Binding<Bool>(
                            get: { offset == type.rawValue },
                            set: { selected in
                                if selected {
                                    offset = type.rawValue
                                }
                            }
                        )
                    )
                }
            }
        }
    }
    
    
    
}
