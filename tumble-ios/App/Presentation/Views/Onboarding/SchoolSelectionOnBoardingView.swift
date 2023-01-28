//
//  SchoolSelectionOnBoardingView.swift
//  tumble-ios
//
//  Created by Adis Veletanlic on 2023-01-28.
//

import SwiftUI

typealias OnSelectSchool = (School) -> Void

struct SchoolSelectionOnBoardingView: View {
    
    let onSelectSchool: OnSelectSchool
    
    var body: some View {
        List(schools.sorted { $0.name < $1.name }, id: \.id) { school in
            SchoolRow(school: school)
                .onTapGesture(perform: {
                    onSelectSchool(school)
                })
        }
        .padding(.bottom, 30)
    }
}
