//
//  SchoolsList.swift
//  tumble-ios
//
//  Created by Adis Veletanlic on 11/16/22.
//

import Foundation
import SwiftUI


struct SchoolsList: View {
    var body: some View {
        NavigationView {
            List(schools) { school in
                SchoolRow(school: school)
            }.navigationTitle("Select university")
        }
    }
}

struct SchoolsList_Previews: PreviewProvider {
    static var previews: some View {
        SchoolsList()
    }
}
