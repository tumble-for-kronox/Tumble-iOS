//
//  CustomBackButton.swift
//  tumble-ios
//
//  Created by Adis Veletanlic on 2023-02-14.
//

import Foundation
import SwiftUI

struct NavigationButtonModifier: ViewModifier {
    
    let previousPage: String
    let callback: (() -> Void)?
    
    init(previousPage: String, callback: (() -> Void)? = nil) {
        self.previousPage = previousPage
        self.callback = callback
    }
    
    func body(content: Content) -> some View {
        content
            .navigationBarBackButtonHidden(true)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading, content: {
                    BackButton(previousPage: previousPage, callback: callback)
                })
            }
    }
}

    
