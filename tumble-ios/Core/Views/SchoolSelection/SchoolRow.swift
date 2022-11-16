//
//  SchoolRow.swift
//  tumble-ios
//
//  Created by Adis Veletanlic on 11/16/22.
//

import Foundation
import SwiftUI

struct SchoolRow: View {
    var school: School
    var body: some View {
        HStack {
            school.logo
                .resizable()
                .frame(width: 60, height: 60)
                .padding(.trailing, 25)
            Text(school.name)
                .padding(.top, 32)
                .font(.system(size: 20))
        }
        .padding(.bottom, 20)
        .padding(.top, 10)
    }
}

struct SchoolRow_Previews: PreviewProvider {
    static var previews: some View {
        SchoolRow(school: schools[0])
    }
}
