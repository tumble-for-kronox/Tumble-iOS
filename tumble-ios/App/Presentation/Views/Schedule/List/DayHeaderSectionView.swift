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
                .dayHeader()
            Text(day.date)
                .dayHeader()
            Rectangle()
                .fill(Color("OnBackground"))
                .offset(x: 7.5)
                .frame(height: 1.5)
                .padding(.trailing, 8)
            Spacer()
        }
        .padding(.leading, 10)
    }
}
