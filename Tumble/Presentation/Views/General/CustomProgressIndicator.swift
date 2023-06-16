//
//  CustomProgressView.swift
//  Tumble
//
//  Created by Adis Veletanlic on 11/19/22.
//

import SwiftUI
import Combine

struct CustomProgressIndicator: View {
    let timer: Publishers.Autoconnect<Timer.TimerPublisher>
        let timing: Double
        
        let maxCounter = 3
        @State var counter = 0
        
        let frame: CGSize
        let primaryColor: Color
        
        init(color: Color = .primary, size: CGFloat = 25, speed: Double = 0.25) {
            timing = speed
            timer = Timer.publish(every: timing, on: .main, in: .common).autoconnect()
            frame = CGSize(width: size, height: size)
            primaryColor = color
        }

        var body: some View {
            HStack(spacing: 0) {
                ForEach(0..<3) { index in
                    Circle()
                        .scale(counter == index ? 1.0 : 0.5)
                        .fill(primaryColor)
                }
            }
            .frame(width: frame.width, height: frame.height, alignment: .center)
            .onReceive(timer, perform: { _ in
                withAnimation(.linear(duration: timing)) {
                    counter = counter == (maxCounter - 1) ? 0 : counter + 1
                }
            })
        }
}

