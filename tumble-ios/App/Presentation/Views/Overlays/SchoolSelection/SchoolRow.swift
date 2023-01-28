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
                .aspectRatio(contentMode: .fit)
                .frame(width: 50, height: 50)
                .foregroundColor(Color("PrimaryColor"))
                .frame(width: 60)
                .padding(10)
            
            VStack (alignment: .center) {
                Spacer()
                Text(school.name)
                    .titleSchool()
                Spacer()
                
            }
            .frame(height: 80, alignment: .top)
            .padding(.trailing, 10)
            .padding([.top, .bottom], 10)
            Spacer()
        }
        .frame(minWidth: 0, maxWidth: .infinity, minHeight: 70, alignment: .center)
        .background(Color("SurfaceColor"))
        .cornerRadius(10)
        .padding([.leading, .trailing], 20)
        .padding([.bottom, .top], 10)
    }
}

struct SchoolRow_Previews: PreviewProvider {
    static var previews: some View {
        SchoolRow(school: schools[0])
    }
}
