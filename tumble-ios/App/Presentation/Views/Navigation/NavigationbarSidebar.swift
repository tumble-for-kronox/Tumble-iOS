//
//  SideBarToggleButtonView.swift
//  tumble-ios
//
//  Created by Adis Veletanlic on 2023-02-01.
//

import SwiftUI

struct NavigationbarSidebar: View {
    
    @Binding var showSideBar: Bool
    let handleClose: (Bool) -> Void
    
    var body: some View {
        Button(action: {
            withAnimation(.spring()) {
                handleClose(showSideBar ? false : true)
            }
        }, label: {
            VStack (spacing: 5) {
                if showSideBar {
                    Image(systemName: "xmark")
                        .font(.system(size: 20))
                        .foregroundColor(.onBackground)
                } else {
                    Capsule()
                       .fill(Color.onBackground.opacity(0.8))
                       .frame(width: 25, height: 2)
                       .cornerRadius(10)
                   Capsule()
                      .fill(Color.onBackground.opacity(0.8))
                      .frame(width: 25, height: 2)
                      .cornerRadius(10)
                   Capsule()
                      .fill(Color.onBackground.opacity(0.8))
                      .frame(width: 25, height: 2)
                      .cornerRadius(10)
                }
            }
        })
    }
}

