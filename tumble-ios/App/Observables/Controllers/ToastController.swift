//
//  ToastController.swift
//  tumble-ios
//
//  Created by Adis Veletanlic on 2023-03-12.
//

import Foundation

class ToastController: ObservableObject {
    @Published var toast: Toast?
    
    func showToast(style: ToastStyle, title: String, message: String? = nil) {
        self.toast = Toast(type: style, title: title, message: message ?? "")
    }
    
    func hideToast() {
        self.toast = nil
    }
}
