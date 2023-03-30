//
//  Toast.swift
//  tumble-ios
//
//  Created by Adis Veletanlic on 11/16/22.
//
// Source code for this toast:
// https://betterprogramming.pub/swiftui-create-a-fancy-toast-component-in-10-minutes-e6bae6021984

import SwiftUI

struct ToastView: View {
    
    var type: ToastStyle
    var title: String
    var message: String
    var onCancelTapped: (() -> Void)
    
    var body: some View {
        VStack(alignment: .leading) {
            HStack(alignment: .top) {
                Image(systemName: type.iconFileName)
                    .foregroundColor(type.themeColor)
                
                VStack(alignment: .leading) {
                    Text(title)
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(.onBackground)
                    
                    Text(message)
                        .font(.system(size: 12))
                        .foregroundColor(.onBackground.opacity(0.6))
                }
                
                Spacer(minLength: 10)
                
                Button {
                    onCancelTapped()
                } label: {
                    Image(systemName: "xmark")
                        .foregroundColor(.onBackground)
                }
            }
            .padding()
        }
        .background(Color(UIColor.systemBackground))
        .overlay(
            Rectangle()
                .fill(type.themeColor)
                .frame(width: 6)
                .clipped()
            , alignment: .leading
        )
        .frame(minWidth: 0, maxWidth: .infinity)
        .cornerRadius(8)
        .shadow(color: Color.black.opacity(0.25), radius: 4, x: 0, y: 1)
        .padding(.horizontal, 16)
        .padding(.bottom, 15)
    }
}
