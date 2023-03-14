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
    let onTap: () -> Void
    @Namespace private var pillNamespace
    
    var body: some View {
        Button(action: {
            HapticsController.triggerHapticLight()
            onTap()
        }, label: {
            HStack {
                Image(systemName: image)
                    .font(.system(size: 14))
                    .foregroundColor(.onSurface)
                Text(title)
                    .font(.system(size: 15, weight: .semibold, design: .rounded))
                    .multilineTextAlignment(.leading)
                    .foregroundColor(.onSurface)
                    .matchedGeometryEffect(id: title, in: pillNamespace)
            }
            .padding(.all, 10)
        })
        .buttonStyle(EventDetailsPillStyle())
    }
}
