//
//  SchedulePageMainView.swift
//  tumble-ios
//
//  Created by Adis Veletanlic on 11/21/22.
//

import SwiftUI

struct ScheduleMainPageView: View {
    @ObservedObject var viewModel: ScheduleMainPageViewModel
    let onTapCard: OnTapCard
    var body: some View {
        VStack (alignment: .center) {
            switch viewModel.status {
            case .loading:
                Spacer()
                CustomProgressView()
                Spacer()
            case .loaded:
                VStack {
                    Picker("ViewType", selection: $viewModel.defaultViewType) {
                        ForEach(viewModel.scheduleViewTypes, id: \.self) {
                            Text($0.rawValue)
                                .foregroundColor(.onSurface)
                                .font(.caption)
                        }
                    }
                    .onChange(of: viewModel.defaultViewType) { defaultViewType in
                        viewModel.onChangeViewType(viewType: defaultViewType)
                    }
                    .padding(.leading, 10)
                    .padding(.trailing, 10)
                    .padding(.top, 10)
                    .pickerStyle(SegmentedPickerStyle())
                    .foregroundColor(.primary)
                    
                    switch viewModel.defaultViewType {
                    case .list:
                        ScheduleListView(days: viewModel.days, courseColors: viewModel.courseColors, onTapCard: onTapCard)
                    case .calendar:
                        Text("stub")
                            .padding(.top, 10)
                    }
                }
            case .uninitialized:
                InfoView(title: "No bookmarked schedules", image: "bookmark.slash")
            case .error:
                InfoView(title: "There was an error retrieving your schedules", image: "exclamationmark.circle")
            }
        }
    }
}

