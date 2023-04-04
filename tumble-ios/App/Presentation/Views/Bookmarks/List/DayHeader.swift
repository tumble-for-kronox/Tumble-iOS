//
//  DayHeaderSectionView.swift
//  tumble-ios
//
//  Created by Adis Veletanlic on 11/21/22.
//


import SwiftUI

struct DayHeader: View {
    let day: DayUiModel
    var body: some View {
        HStack (spacing: 0) {
            Text(NSLocalizedString(localizedKey(for: day.name), comment: ""))
                .dayHeader()
            Text(day.date)
                .dayHeader()
            Rectangle()
                .fill(Color.onBackground)
                .offset(x: 7.5)
                .frame(height: 1)
                .cornerRadius(20)
                .padding(.trailing, 8)
            Spacer()
        }
        .padding(.leading, 10)
    }
    
    fileprivate func localizedKey(for inputString: String) -> String {
        return "\(inputString)"
    }

    
}
