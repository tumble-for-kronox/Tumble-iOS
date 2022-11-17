//
//  DrawerContent.swift
//  tumble-ios
//
//  Created by Adis Veletanlic on 11/16/22.
//

import SwiftUI

struct DrawerItem: Identifiable {
    var id: UUID = UUID()
    let text: String
}

struct DrawerContent: View {
    var body: some View {
        ZStack {
            Color("BackgroundColor")
            VStack(alignment: .leading, spacing: 0) {
                VStack {
                    Text("Common")
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.leading, 20)
                        .padding(.bottom, 5)
                        .font(.system(size: 14))
                        .bold()
                    
                    DrawerRow(title: "Change school", description: "Current school: SCHOOL", image: "arrow.left.arrow.right")
                    DrawerRow(title: "Change theme", description: "Current theme: THEME", image: "iphone.gen3")
                    DrawerRow(title: "Change language", description: "Current language: LANG", image: "textformat.abc.dottedunderline")
                    
                }
                .padding(.bottom, 20)
                Divider().padding(.bottom, 15)
                VStack {
                    Text("Schedule")
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.leading, 20)
                        .padding(.bottom, 5)
                        .font(.system(size: 14))
                        .bold()
                    
                    DrawerRow(title: "Toggle schedules", description: "Set which schedules are shown", image: "bookmark")
                    
                }
                .padding(.bottom, 20)
                Divider().padding(.bottom, 15)
                VStack {
                    Text("Notifications")
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.leading, 20)
                        .padding(.bottom, 5)
                        .font(.system(size: 14))
                        .bold()
                    
                    DrawerRow(title: "Cancel all", description: "Cancel all set notifications", image: "bell.slash")
                    DrawerRow(title: "Notification offset", description: "Current offset: NOTIF_OFFSET", image: "clock.arrow.circlepath")
                }
                .padding(.bottom, 15)
                Spacer()
            }
            .padding(.top, 75)
        }
    }
}

struct DrawerContent_Previews: PreviewProvider {
    static var previews: some View {
        DrawerContent()
    }
}
