//
//  ContentView.swift
//  tumble-ios
//
//  Created by Adis Veletanlic on 11/16/22.
//


import SwiftUI

struct SchoolSelectView: View {
    var selectSchoolCallback: (School) -> Void
    var body: some View {
        HStack {
            List(schools.sorted { $0.name < $1.name }, id: \.id) { school in
                SchoolRow(school: school)
                    .onTapGesture(perform: {
                        selectSchoolCallback(school)
                    })
            }
        }
    }
}
