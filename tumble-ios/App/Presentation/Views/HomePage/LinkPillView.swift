//
//  LinkPillView.swift
//  tumble-ios
//
//  Created by Adis Veletanlic on 2023-02-03.
//

import SwiftUI

struct LinkPillView: View {
    let title: String
    let image: String
    let url: URL?
    var body: some View {
        Button(action: {
            if url != nil {
                UIApplication.shared.open(self.url!)
            }
        }, label: {
            HStack {
                Image(systemName: image)
                    .font(.system(size: 14))
                    .foregroundColor(.onSurface)
                Text(title)
                    .font(.system(size: 15, weight: .semibold, design: .rounded))
                    .foregroundColor(.onSurface)
            }
            .padding(.all, 10)
            .background(Color.surface)
            .cornerRadius(20)
        })
    }
}
