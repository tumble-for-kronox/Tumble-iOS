//
//  CardView.swift
//  tumble-ios
//
//  Created by Adis Veletanlic on 2023-01-27.
//

import SwiftUI

struct EventSheetView<Content: View>: View {
    @Binding var eventSheetPositionSize: CGSize
    let animateEventSheetOutOfView: () -> Void
    let content: () -> Content
    
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 20)
                .fill(Color("SurfaceColor"))
                .offset(y: 35)
                .padding(.top, 300)
                .shadow(radius: 5)
            content()
        }
        .offset(y: eventSheetPositionSize.height)
        .animation(.spring().speed(2.0))
        .gesture(
            DragGesture()
                .onChanged { value in
                    self.eventSheetPositionSize = value.translation
                }
                .onEnded { value in
                    if self.eventSheetPositionSize.height > 200 {
                        self.animateEventSheetOutOfView()
                    }
                    else {
                        self.eventSheetPositionSize = .zero
                    }
                }
        )
    }
}

