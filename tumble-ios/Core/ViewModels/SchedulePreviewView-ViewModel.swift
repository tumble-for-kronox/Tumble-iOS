//
//  SchedulePreviewView-ViewModel.swift
//  tumble-ios
//
//  Created by Adis Veletanlic on 11/18/22.
//

import Foundation

enum SchedulePreviewStatus {
    case loading
    case loaded
    case empty
}

extension SchedulePreviewView {
    @MainActor class SchedulePreviewViewModel: ObservableObject {
        @Published var status: SchedulePreviewStatus = .loading
    
    }
}
