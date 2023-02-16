//
//  UserAvatar.swift
//  tumble-ios
//
//  Created by Adis Veletanlic on 2023-02-13.
//

import SwiftUI

struct UserAvatar: View {
    
    @Binding var image: UIImage?
    
    let name: String
    
    var body: some View {
        
        if let image = self.image {
            Image(uiImage: image)
                .resizable()
                .scaledToFill()
                .clipShape(Circle())
                .frame(width: 80, height: 80)
                .overlay(
                    Image(systemName: "plus.circle.fill")
                        .font(.system(size: 22, design: .rounded))
                        .foregroundColor(.primary)
                        .background(Circle().fill(Color.background))
                    ,alignment: .bottomTrailing
                )
                
                
        } else {
            Text(name.abbreviate())
                .font(.system(size: 40, weight: .semibold, design: .rounded))
                .foregroundColor(.onPrimary)
                .padding()
                .background(Circle().fill(Color("PrimaryColor")))
                .overlay(
                    Image(systemName: "plus.circle.fill")
                        .font(.system(size: 22, design: .rounded))
                        .foregroundColor(.primary)
                        .background(Circle().fill(Color.background))
                    ,alignment: .bottomTrailing
                )
        }
    }
}

