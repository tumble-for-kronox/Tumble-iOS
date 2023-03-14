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
                    .frame(width: 50, height: 50)
                    .foregroundColor(.primary)
                    .frame(width: 60)
                    .padding(10)
                
                VStack (alignment: .leading) {
                    Spacer()
                    Text(school.name)
                        .titleSchool()
                    Spacer()
                    
                }
                .frame(height: 80, alignment: .top)
                .padding(.trailing, 10)
                .padding([.top, .bottom], 10)
                Spacer()
                Image(systemName: "chevron.right")
                    .padding([.leading, .trailing], 20)
            }
        })
        .buttonStyle(SchoolRowStyle())
    }
}

