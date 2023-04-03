//
//  ListRowActionItem.swift
//  tumble-ios
//
//  Created by Adis Veletanlic on 2023-04-02.
//

import SwiftUI

struct ListRowActionItem: View {
    let title: String
    let current: String?
    let action: () -> Void
    let image: String
    let imageColor: Color
    
    init(
        title: String,
        current: String? = nil,
        image: String = "chevron.right",
        imageColor: Color = Color.onSurface,
        action: @escaping () -> Void
    ) {
        self.title = title
        self.current = current
        self.image = image
        self.imageColor = imageColor
        self.action = action
    }
    
    var body: some View {
        Button(action: {
            HapticsController.triggerHapticLight()
            action()
        }, label: {
            HStack (spacing: 0) {
                Text(title)
                    .font(.system(size: 16, weight: .regular))
                    .foregroundColor(.onSurface)
                Spacer()
                if let current = current {
                    Text(current)
                        .font(.system(size: 16, weight: .regular))
                        .foregroundColor(.onSurface.opacity(0.7))
                        .padding(.trailing, 10)
                }
                Image(systemName: image)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(imageColor.opacity(0.5))
            }
            .padding(2.5)
        })
    }
}

