//
//  ViewExtensions.swift
//  Tumble
//
//  Created by Adis Veletanlic on 11/16/22.
//

import Foundation
import SwiftUI

extension View {
    @ViewBuilder func `if`<Content: View>(_ condition: Bool, transform: (Self) -> Content) -> some View {
        if condition {
            transform(self)
        } else {
            self
        }
    }
    
    func eraseToAnyView() -> AnyView {
        AnyView(self)
    }
    
    func onFirstAppear(_ action: @escaping () -> ()) -> some View {
        modifier(FirstAppear(action: action))
    }
    
    func hideKeyboard() {
        let resign = #selector(UIResponder.resignFirstResponder)
        UIApplication.shared.sendAction(resign, to: nil, from: nil, for: nil)
    }
    
    
    func searchBox() -> some View {
        padding(10)
            .background(Color.gray.opacity(0.2))
            .cornerRadius(10)
    }
    
    func getRect() -> CGRect {
        return UIScreen.main.bounds
    }
    
    func sectionDividerEmpty() -> some View {
        font(.system(size: 16))
            .foregroundColor(.onBackground)
            .padding(.top, 5)
    }
}
