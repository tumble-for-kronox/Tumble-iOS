//
//  SupportView.swift
//  tumble-ios
//
//  Created by Adis Veletanlic on 2023-01-28.
//

import SwiftUI

struct Support: View {
    var body: some View {
        VStack {
            SidebarSheetButton(image: "ant", title: "Report a bug", onClick: {})
            SidebarSheetButton(image: "person.2", title: "Contributors", onClick: {})
            SidebarSheetButton(image: "info.circle", title: "How to use the app", onClick: {})
        }
    }
}

struct SupportView_Previews: PreviewProvider {
    static var previews: some View {
        Support()
    }
}
