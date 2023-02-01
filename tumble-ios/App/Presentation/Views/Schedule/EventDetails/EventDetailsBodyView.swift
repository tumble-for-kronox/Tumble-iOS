//
//  EventDetailsBodyView.swift
//  tumble-ios
//
//  Created by Adis Veletanlic on 2023-02-01.
//

import SwiftUI

struct EventDetailsBodyView: View {
    
    let event: Response.Event
    
    var body: some View {
        VStack (alignment: .leading) {
            HStack {
                Text("Details")
                    .font(.system(size: 16, design: .rounded))
                    .bold()
                    .padding(.leading, 15)
                Rectangle()
                    .fill(Color.onBackground)
                    .offset(x: 7.5)
                    .frame(height: 1.5)
                    .padding(.trailing, 25)
            }
            
        }
    }
}

