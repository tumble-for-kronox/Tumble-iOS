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
                Spacer()
                CustomProgressView()
                Spacer()
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
                    .padding(.top, 10)
                    .pickerStyle(SegmentedPickerStyle())
                    .foregroundColor(Color("PrimaryColor"))
                    
                    switch viewModel.viewType {
                    case .list:
                        ScheduleListView(days: viewModel.days, courseColors: viewModel.courseColors)
                    case .calendar:
                        ScheduleCalendarView()
                            .padding(.top, 10)
                    }
                    Spacer()
                }
            case .uninitialized:
                Spacer()
                InfoView(title: "No bookmarked schedules", image: "bookmark.slash")
                Spacer()
            case .error:
                Spacer()
                InfoView(title: "There was an error retrieving your schedules", image: "exclamationmark.circle")
                Spacer()
            }
        }
    }
}

struct ScheduleMainPageView_Previews: PreviewProvider {
    static var previews: some View {
        ScheduleMainPageView()
    }
}
