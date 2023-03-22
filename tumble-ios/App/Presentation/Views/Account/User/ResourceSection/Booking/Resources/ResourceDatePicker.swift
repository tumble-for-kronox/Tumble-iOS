//
//  ResourceDatePicker.swift
//  tumble-ios
//
//  Created by Adis Veletanlic on 2023-03-22.
//

import SwiftUI

struct ResourceDatePicker: View {
    
    @Binding var date: Date
    
    var body: some View {
        DatePicker("Pick a date", selection: $date, displayedComponents: [.date, .hourAndMinute])
            .padding()
            .datePickerStyle(.graphical)
            .accentColor(Color.primary)
            .background(Color.background)
    }
}

struct ResourceDatePicker_Previews: PreviewProvider {
    static var previews: some View {
        ResourceDatePicker(date: .constant(Date.now))
    }
}
