//
//  EventDetailsView-ViewModel.swift
//  tumble-ios
//
//  Created by Adis Veletanlic on 2023-02-01.
//

import Foundation
import SwiftUI

extension EventDetailsSheetView {
    @MainActor final class EventDetailsViewModel: ObservableObject {
        @Published var event: Response.Event?
        @Published var color: Color?
        
        init(event: Response.Event?, color: Color?) {
            self.event = event
            self.color = color
        }
        
        func setEventSheetView(event: Response.Event, color: Color) -> Void {
            self.event = event
            self.color = color
        }
        
    }
}
