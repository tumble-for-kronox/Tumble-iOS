//
//  UserResult.swift
//  tumble-ios
//
//  Created by Adis Veletanlic on 2023-03-05.
//

import Foundation

struct GetUserEventsResult {
    let userEvents: Response.KronoxCompleteUserEvent?
    let error: GetUserEventsError?
}
