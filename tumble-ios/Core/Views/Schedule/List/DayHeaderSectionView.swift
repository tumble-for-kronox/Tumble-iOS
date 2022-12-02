//
//  DayHeaderSectionView.swift
//  tumble-ios
//
//  Created by Adis Veletanlic on 11/21/22.
//


import SwiftUI

struct DayHeaderSectionView: View {
    let day: DayUiModel
    var body: some View {
        HStack (spacing: 0) {
            Text(day.name)
                .font(.title2)
                .bold()
                .padding(.trailing, 10)
            Text(day.date)
                .bold()
                .font(.title2)
            Spacer()
        }
        .padding(.leading, 20)
    }
}
