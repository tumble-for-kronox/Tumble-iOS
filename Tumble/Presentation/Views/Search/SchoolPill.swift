//
//  SchoolPill.swift
//  Tumble
//
//  Created by Adis Veletanlic on 4/19/23.
//

import SwiftUI

struct SchoolPill: View, Pill {
    
    var id: UUID = UUID()

    let school: School
    
    var title: String
    
    var icon: Image
    
    @Binding var selectedSchool: School?
    
    
    init(school: School, selectedSchool: Binding<School?>) {
        self._selectedSchool = selectedSchool
        self.title = school.domain.uppercased()
        self.icon = school.logo
        self.school = school
    }
    
    var body: some View {
        Button(action: {
            withAnimation(.spring()) {
                if isSelected() {
                    selectedSchool = nil
                } else {
                    selectedSchool = school
                }
            }
        }, label: {
            HStack {
                icon
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: fontSize, height: fontSize)
                    .cornerRadius(40)
                Text(title)
                    .font(.system(size: fontSize, weight: .semibold))
                    .foregroundColor(isSelected() ? .onPrimary : .onSurface)
            }
        })
        .buttonStyle(PillStyle(color: isSelected() ? .primary : .surface))
        .padding(5)
    }
    
    var fontSize: CGFloat {
        isSelected() ? 18 : 16
    }
    
    func isSelected() -> Bool {
        return selectedSchool == school
    }
}
