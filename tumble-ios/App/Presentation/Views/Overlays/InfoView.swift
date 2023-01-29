//
//  InfoView.swift
//  tumble-ios
//
//  Created by Adis Veletanlic on 11/28/22.
//

import SwiftUI

struct InfoView: View {
    let title: String
    let image: String?
    var body: some View {
        
        if image != nil {
            Image(systemName: image!)
                .font(.system(size: 24))
                .foregroundColor(Color("OnBackground"))
                .padding(.bottom, 15)
        }
        Text(title)
            .info()
        
    }
}
