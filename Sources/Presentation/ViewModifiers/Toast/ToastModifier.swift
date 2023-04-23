//
//  ToastModifier.swift
//  Tumble
//
//  Created by Adis Veletanlic on 11/16/22.
//

import Foundation
import SwiftUI

struct ToastModifier: ViewModifier {
    @Binding var toast: Toast?
    @State private var workItem: DispatchWorkItem?
    
    func body(content: Content) -> some View {
        content
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .overlay(
                ZStack {
                    mainToastView()
                        .offset(y: -20)
                }
                .animation(.spring(), value: toast)
            )
            .onChange(of: toast) { _ in
                showToast()
            }
    }
    
    @ViewBuilder func mainToastView() -> some View {
        if let toast = toast {
            VStack {
                Spacer()
                ToastView(
                    type: toast.type,
                    title: toast.title,
                    message: toast.message
                ) {
                    dismissToast()
                }
            }
            .transition(.move(edge: .bottom))
        }
    }
    
    private func showToast() {
        guard let toast = toast else { return }
        
        HapticsController.triggerHapticLight()
        
        if toast.duration > 0 {
            workItem?.cancel()
            
            let task = DispatchWorkItem {
                dismissToast()
            }
            
            workItem = task
            DispatchQueue.main.asyncAfter(deadline: .now() + toast.duration, execute: task)
        }
    }
    
    private func dismissToast() {
        withAnimation {
            toast = nil
        }
        
        workItem?.cancel()
        workItem = nil
    }
}
