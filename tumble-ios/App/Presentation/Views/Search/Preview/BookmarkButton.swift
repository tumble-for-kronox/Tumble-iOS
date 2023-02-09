//
//  BookmarkButton.swift
//  tumble-ios
//
//  Created by Adis Veletanlic on 2023-02-09.
//

import SwiftUI

struct BookmarkButton: View {
    
    var animation: Namespace.ID
    
    let title: String
    let image: String
    
    var body: some View {
        HStack (spacing: 10) {
            Image(systemName: image)
                .font(.system(size: 20))
                .foregroundColor(.onPrimary)
            Text(title)
                .font(.system(size: 20, weight: .semibold, design: .rounded))
                .foregroundColor(.onPrimary)
        }
        .matchedGeometryEffect(id: "BOOKMARKBTN", in: animation)
    }
}
