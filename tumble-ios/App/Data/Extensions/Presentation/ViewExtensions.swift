//
//  ViewExtensions.swift
//  tumble-ios
//
//  Created by Adis Veletanlic on 11/16/22.
//

import Foundation
import SwiftUI

extension View {
    
    @ViewBuilder func `if`<Content : View>(_ condition: Bool, transform: (Self) -> Content) -> some View {
        if condition {
            transform(self)
        } else {
            self
        }
    }
    
    func toastView(toast: Binding<Toast?>) -> some View {
        self.modifier(ToastModifier(toast: toast))
    }
    
    func hideKeyboard() {
        let resign = #selector(UIResponder.resignFirstResponder)
        UIApplication.shared.sendAction(resign, to: nil, from: nil, for: nil)
    }
    
    func cornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
        clipShape( RoundedCorner(radius: radius, corners: corners) )
    }
    
    func eventDetailsSheet<Content>(isPresented: Binding<Bool>, onDismiss: (() -> Void)? = nil, @ViewBuilder content: @escaping () -> Content)
        -> some View where Content : View {
        ZStack {
            if isPresented.wrappedValue {
                content()
                    .transition(.move(edge: .bottom))
            }
        }
    }
    
    func searchBox() -> some View {
        self.padding(10)
        .background(.gray.opacity(0.25))
        .cornerRadius(10)
        .padding(.leading, 20)
        .padding(.trailing, 20)
        .padding(.bottom, 35)
        .padding(.top, 25)
    }
    
    func getRect() -> CGRect {
        return UIScreen.main.bounds
    }
}
