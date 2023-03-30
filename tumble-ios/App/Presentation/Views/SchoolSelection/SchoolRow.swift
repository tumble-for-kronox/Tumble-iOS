//
//  SchoolRow.swift
//  tumble-ios
//
//  Created by Adis Veletanlic on 11/16/22.
//

import Foundation
import SwiftUI

struct SchoolRow: View {
    
    let school: School
    let onSelectSchool: (School) -> Void
    
    var body: some View {
        Button(action: {
            HapticsController.triggerHapticLight()
            onSelectSchool(school)
        }, label: {
            HStack {
                school.logo
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 40, height: 40)
                    .frame(width: 50)
                    .padding(10)
                
                VStack (alignment: .leading) {
                    Spacer()
                    Text(school.name)
                        .titleSchool()
                    Spacer()
                    
                }
                .frame(height: 60, alignment: .top)
                .padding(.trailing, 10)
                .padding([.top, .bottom], 10)
                Spacer()
            }
        })
    }
}

