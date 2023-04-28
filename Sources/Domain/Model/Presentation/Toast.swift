//
//  Toast.swift
//  Tumble
//
//  Created by Adis Veletanlic on 11/16/22.
//

import Foundation

struct Toast: Equatable {
    var type: ToastStyle
    var title: String
    var message: String
    var duration: Double = 5
}
