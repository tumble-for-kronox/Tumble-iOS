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
        NavigationView {
            HStack {
                List(schools, id: \.id) { school in
                    SchoolRow(school: school)
                        .onTapGesture(perform: {
                            selectSchoolCallback(school)
                        })
                }
            }
        }
    }
}
