//
//  SchedulePreviewView.swift
//  tumble-ios
//
//  Created by Adis Veletanlic on 11/18/22.
//

import SwiftUI

struct SchedulePreviewView: View {
    @EnvironmentObject var parentVieweModel: SearchView.SearchViewModel
    @StateObject var viewModel: SchedulePreviewViewModel = SchedulePreviewViewModel()
    var body: some View {
        VStack {
            if !(parentVieweModel.scheduleForPreview == nil) {
                List(parentVieweModel.scheduleForPreview!.days.map { (day) -> DayUiModel in
                    return DayUiModel(
                        name: day.name,
                        date: day.date,
                        isoString: day.isoString,
                        weekNumber: day.weekNumber,
                        events: day.events)
                }) { day in
                    ScheduleCardView(day: day)
                }.listRowBackground(Color.green)
            } else {
                ProgressView()
            }
        }
    }
}

extension API.Types.Response.Day {
    func toIdModel(days: [API.Types.Response.Day]) -> [DayUiModel] {
        return days.map { (day) -> DayUiModel in
            return DayUiModel(
                name: day.date,
                date: day.date,
                isoString: day.isoString,
                weekNumber: day.weekNumber,
                events: day.events)
        }
    }
}

struct DayUiModel: Identifiable {
    let id: UUID = UUID()
    let name, date: String
    let isoString: String
    let weekNumber: Int
    let events: [API.Types.Response.Event]
}
