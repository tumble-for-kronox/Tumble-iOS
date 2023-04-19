//
//  ResourceDetailSheetModel.swift
//  tumble-ios
//
//  Created by Adis Veletanlic on 2023-04-01.
//

import Foundation

struct ResourceDetailSheetModel: Identifiable {
    var id: UUID = UUID()
    let resource: Response.KronoxUserBookingElement
}