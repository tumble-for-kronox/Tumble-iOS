//
//  TabItem.swift
//  Tumble
//
//  Created by Adis Veletanlic on 5/5/23.
//

import SwiftUI

struct TabItem: View {
    
    let appTab: TabbarTabType
    
    var body: some View {
        VStack {
            let uiImage = UIImage(systemName: appTab.rawValue)?.resizeImage(targetSize: CGSize(width: 23, height: 23))
            Image(uiImage: uiImage!)
            Text(appTab.displayName)
        }
    }
}
