//
//  SchedulePageMainView.swift
//  tumble-ios
//
//  Created by Adis Veletanlic on 11/21/22.
//

import SwiftUI

struct BookmarkPage: View {
    
    @ObservedObject var viewModel: BookmarkPageViewModel
    let onTapCard: OnTapCard
    let createToast: (ToastStyle, String, String) -> Void
    @Binding var eventSheet: EventSheetModel?
    
    
    var body: some View {
        VStack (alignment: .center) {
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
                
                switch viewModel.status {
                case .loading:
                    Spacer()
                    HStack {
                        Spacer()
                        CustomProgressIndicator()
                        Spacer()
                    }
                    Spacer()
                case .loaded:
                    
                    switch viewModel.defaultViewType {
                    case .list:
                        BookmarkListView(days: viewModel.scheduleListOfDays, courseColors: viewModel.courseColors, onTapCard: onTapCard)
                            .refreshable {
                                
                            }
                    case .calendar:
                        Text("stub")
                            .padding(.top, 10)
                    }
                case .uninitialized:
                    Info(title: "No bookmarked schedules", image: "bookmark.slash")
                case .error:
                    Info(title: "There was an error retrieving your schedules", image: "exclamationmark.circle")
                }
            }
        }
        .sheet(item: $eventSheet) { (eventSheet: EventSheetModel) in
            EventDetailsSheet(viewModel: viewModel.generateViewModelEventSheet(event: eventSheet.event, color: eventSheet.color), createToast: createToast)
        }
    }
}

