//
//  ViewExtensions.swift
//  tumble-ios
//
//  Created by Adis Veletanlic on 11/16/22.
//

import Foundation
import SwiftUI

extension View {
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
    
    func featureIcon() -> some View {
        self.font(.system(size: 20))
            .foregroundColor(Color("PrimaryColor"))
    }
    
    func featureText() -> some View {
        self.font(.system(size: 20))
            .foregroundColor(Color("OnSurface"))
    }
    
    func homePageOption() -> some View {
        self
            .font(.system(size: 17))
            .foregroundColor(Color("OnSurface"))
            .padding(.trailing, 15)
            .padding(.leading, 15)
    }
    
    func homePageOptionIcon(color: Color) -> some View {
        self
            .font(.system(size: 20))
            .frame(width: 17, height: 17)
            .padding(15)
            .foregroundColor(Color("OnPrimary"))
            .background(color)
            .clipShape(RoundedRectangle(cornerRadius: 7.5))
    }
    
    func optionBigIcon() -> some View {
        self.font(.veryLargeIconFont)
            .padding(.trailing, 24)
            .foregroundColor(Color("OnBackground"))
    }
}

extension Text {
    func dayOfWeek() -> some View {
        self.frame(maxWidth: .infinity)
            .padding(.top, 1)
            .lineLimit(1)
    }
    
    func mainheader() -> some View {
        self.font(.system(size: 23))
            .bold()
            .padding(.top, 20)
            .foregroundColor(Color("PrimaryColor"))
    }
    
    func subHeader() -> some View {
        self.font(.system(size: 22))
        .bold()
        .padding([.leading, .trailing], 20)
    }
}
