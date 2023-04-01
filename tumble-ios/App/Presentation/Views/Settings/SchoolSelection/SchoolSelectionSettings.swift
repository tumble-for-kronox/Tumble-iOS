//
//  SchoolSelectionSettings.swift
//  tumble-ios
//
//  Created by Adis Veletanlic on 3/29/23.
//

import SwiftUI

struct SchoolSelectionSettings: View {
    
    @Environment(\.presentationMode) var presentationMode
    let onChangeSchool: (School) -> Void
    let schools: [School]
    
    var body: some View {
        SchoolSelection(onSelectSchool: { school in
            onChangeSchool(school)
            presentationMode.wrappedValue.dismiss()
        }, schools: schools)
    }
}
