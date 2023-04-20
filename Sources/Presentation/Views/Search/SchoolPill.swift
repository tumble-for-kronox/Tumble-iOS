//
//  SchoolPill.swift
//  tumble-ios
//
//  Created by Adis Veletanlic on 4/19/23.
//

import SwiftUI

struct SchoolPill: View {
    @Binding var selectedSchool: School?
    let school: School
    var body: some View {
        Button(action: {
            withAnimation(.easeInOut) {
                selectedSchool = school
            }
        }, label: {
            HStack {
                school.logo
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 14, height: 14)
                    .cornerRadius(40)
                Text(school.name)
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(.onSurface)
                if selectedSchool == school {
                    Image(systemName: "xmark")
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundColor(.onSurface)
                        .padding(.leading, 5)
                        .onTapGesture {
                            withAnimation(.easeInOut) {
                                selectedSchool = nil
                            }
                        }
                }
            }
        })
        .buttonStyle(PillStyle())
        .padding(5)
    }
}
