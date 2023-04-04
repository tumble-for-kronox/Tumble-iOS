//
//  SchoolSelectionOnBoardingView.swift
//  tumble-ios
//
//  Created by Adis Veletanlic on 2023-01-28.
//

import SwiftUI

typealias OnSelectSchool = (School) -> Void

struct SchoolSelection: View {
    
    let onSelectSchool: OnSelectSchool
    let schools: [School]
    
    var body: some View {
        ScrollView (showsIndicators: false) {
            LazyVStack {
                ForEach(schools, id: \.id) { school in
                    SchoolRow(school: school, onSelectSchool: onSelectSchool)
                    if (schools.last != school) {
                        Divider()
                            .padding(.horizontal, 15)
                            .padding(.vertical, 15)
                    }
                }
            }
        }
        .background(Color.background)
    }
}
