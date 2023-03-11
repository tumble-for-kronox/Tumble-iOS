//
//  MoreSidebarSheet.swift
//  tumble-ios
//
//  Created by Adis Veletanlic on 2023-03-10.
//

import SwiftUI

struct MoreSidebarSheet: View {
    var body: some View {
        VStack {
            SidebarSheetButton(image: "paintbrush", title: "Theme", onClick: {})
            SidebarSheetButton(image: "globe.europe.africa", title: "Language", onClick: {})
        }
    }
}

struct MoreSidebarSheet_Previews: PreviewProvider {
    static var previews: some View {
        MoreSidebarSheet()
    }
}
