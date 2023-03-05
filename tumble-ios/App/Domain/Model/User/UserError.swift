//
//  UserError.swift
//  tumble-ios
//
//  Created by Adis Veletanlic on 2023-03-05.
//

import Foundation

enum GetUserEventsError: LocalizedError {
    case invalidSessionToken
    case expiredSessionToken
    case networkError(Error)
    case parseError(Error)
}
