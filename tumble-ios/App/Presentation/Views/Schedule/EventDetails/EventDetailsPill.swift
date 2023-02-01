//
//  EventDetailsPill.swift
//  tumble-ios
//
//  Created by Adis Veletanlic on 2023-02-01.
//

import SwiftUI

struct EventDetailsPill: View {
    let title: String
    let image: String
    var body: some View {
        HStack {
            Image(systemName: image)
                .font(.system(size: 14))
                .foregroundColor(.onSurface)
            Text(title)
                .font(.system(size: 15, design: .rounded))
                .foregroundColor(.onSurface)
        }
        .padding(.all, 10)
        .background(Color.surface)
        .cornerRadius(20)
        
    }
}

struct EventDetailsPill_Previews: PreviewProvider {
    static var previews: some View {
        EventDetailsPill(title: "Notification", image: "bell")
    }
}
