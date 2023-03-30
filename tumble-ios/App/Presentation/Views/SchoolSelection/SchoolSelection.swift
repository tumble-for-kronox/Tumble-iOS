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
    
    var body: some View {
        List {
            ForEach(schools, id: \.id) { school in
                SchoolRow(school: school, onSelectSchool: onSelectSchool)
            }
        }
    }
}

struct SchoolSelectionView_Previews: PreviewProvider {
    static var previews: some View {
        SchoolSelection(onSelectSchool: {school in })
    }
}
