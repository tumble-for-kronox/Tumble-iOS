//
//  MainAppOverlay.swift
//  tumble-ios
//
//  Created by Adis Veletanlic on 2023-01-28.
//

import SwiftUI

struct MainAppOverlay: View {
    var eventSheetToggled: () -> Bool
    var animateEventSheetOutOfView: () -> Void
    var isDrawerOpened: Bool
    var onToggleDrawer: () -> Void
    var body: some View {
        Group {
            if eventSheetToggled() {
                Color.clear
                    .onTapGesture {
                        print("Should be here")
                        self.animateEventSheetOutOfView()
                    }
            }
            
            else if isDrawerOpened {
                Color("BackgroundColor")
                    .opacity(isDrawerOpened ? 0.01 : 0)
                    .onTapGesture {
                        onToggleDrawer()
                    }
            } else {
                Color.clear
                .opacity(0)
                .onTapGesture {
                    print("Should not be here")
                    onToggleDrawer()
                }
            }
        }
    }
}

