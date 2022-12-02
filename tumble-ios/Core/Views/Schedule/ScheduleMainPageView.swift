//
//  SchedulePageMainView.swift
//  tumble-ios
//
//  Created by Adis Veletanlic on 11/21/22.
//

import SwiftUI

struct ScheduleMainPageView: View {
    @StateObject var viewModel: ScheduleMainPageViewModel = ScheduleMainPageViewModel()
    var body: some View {
        VStack (alignment: .center) {
            switch viewModel.status {
            case .loading:
                CustomProgressView()
            case .loaded:
                VStack {
                    Picker("ViewType", selection: $viewModel.viewType) {
                        ForEach(viewModel.scheduleViewTypes, id: \.self) {
                            Text($0.rawValue)
                                .foregroundColor(Color("OnSurface"))
                                .font(.caption)
                        }
                    }
                    .onChange(of: viewModel.viewType) { viewType in
                        viewModel.onChangeViewType(viewType: viewType)
                    }
                    .padding(.leading, 10)
                    .padding(.trailing, 10)
                    .pickerStyle(SegmentedPickerStyle())
                    .foregroundColor(Color("PrimaryColor"))
                    if viewModel.viewType == .list {
                        ScheduleGrouperListView(days: viewModel.days)
                    }
                    if viewModel.viewType == .week {
                        Text("Week")
                    }
                    if viewModel.viewType == .calendar {
                        Text("Calendar")
                    }
                    Spacer()
                }
            case .uninitialized:
                InfoView(title: "No bookmarked schedules", image: "bookmark.slash")
            case .error:
                InfoView(title: "There was an error retrieving your schedules", image: "exclamationmark.circle")
            }
        }
    }
}
