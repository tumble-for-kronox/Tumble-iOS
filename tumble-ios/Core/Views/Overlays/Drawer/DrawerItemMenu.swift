//
//  DrawerItemMenu.swift
//  tumble-ios
//
//  Created by Adis Veletanlic on 11/28/22.
//

import SwiftUI

struct DrawerItemMenu: View {
    let buttons: [Button<<#Label: View#>>]
    var body: some View {
        Menu {
            Button(action: {
                viewModel.onToggleTheme(value: false)
            }, label: {
                Text("Light")
                Image(systemName: "sun.max")
            })
            Button(action: {
                viewModel.onToggleTheme(value: true)
            }, label: {
                Text("Dark")
                Image(systemName: "moon")
            })
            Button(action: {
                viewModel.onDisableOverrideTheme()
            }, label: {
                Text("System")
                Image(systemName: "apps.iphone")
            })
        } label: {
            VStack {
                Image(systemName: "paintbrush")
                    .font(.system(size: 17))
                    .frame(width: 17, height: 17)
                    .foregroundColor(Color("OnPrimary"))
                    .padding(15)
                    .background(Color("PrimaryColor").opacity(95))
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                Text("Theme")
                    .padding(.top, 5)
                    .font(.subheadline)
                    .foregroundColor(Color("OnSurface"))
            }
        }
        .padding(.bottom, 30)
    }
}
