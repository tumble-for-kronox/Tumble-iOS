//
//  SearchInitialView.swift
//  tumble-ios
//
//  Created by Adis Veletanlic on 11/20/22.
//

import SwiftUI
import WrappingHStack

struct SearchInfo: View {
    let schools: [School]
    let gridSpacing: CGFloat = 10.0
    @Binding var selectedSchool: School?
    
    var displayedSchools: [School] {
        guard let selectedSchool = selectedSchool else {
            return schools
        }
        return schools.filter { $0.name == selectedSchool.name }
    }
    
    var body: some View {
        VStack (alignment: .leading) {
            Spacer()
            Text(NSLocalizedString(
                selectedSchool != nil ? "Now try searching" : "Choose a university to start searching", comment: ""))
                .info()
                .multilineTextAlignment(.leading)
                .padding(.bottom, 10)
            WrappingHStack(displayedSchools, id: \.self) { school in
                SchoolPill(selectedSchool: $selectedSchool, school: school)
            }
            .frame(minWidth: 250)
        }
        .padding()
    }
}


