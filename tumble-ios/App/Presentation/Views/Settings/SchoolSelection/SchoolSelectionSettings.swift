//
//  SchoolSelectionSettings.swift
//  tumble-ios
//
//  Created by Adis Veletanlic on 3/29/23.
//

import SwiftUI

struct SchoolSelectionSettings: View {
    
    @Environment(\.dismiss) var dismiss
    let changeSchool: (Int) -> Void
    let schools: [School]
    
    var body: some View {
        SchoolSelection(onSelectSchool: { school in
            changeSchool(school.id)
            dismiss()
        }, schools: schools)
    }
}
