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
        VStack {
            Spacer()
            Picker("Strength", selection: $viewModel.viewType) {
                ForEach(viewModel.scheduleViewTypes, id: \.self) {
                    Text($0.rawValue)
                        .foregroundColor(.white)
                        .font(.caption)
                }
            }
            .onChange(of: viewModel.viewType) { viewType in
                viewModel.onChangeViewType(viewType: viewType)
            }
            .padding(.leading, 10)
            .padding(.trailing, 10)
            .pickerStyle(SegmentedPickerStyle()).foregroundColor(Color("PrimaryColor"))
            Spacer()
        }
    }
}
