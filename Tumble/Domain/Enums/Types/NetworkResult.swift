//
//  NetworkResult.swift
//  Tumble
//
//  Created by Adis Veletanlic on 4/26/23.
//

import Foundation

enum NetworkResult<Success, Failure> where Failure: Swift.Error {
    case success(Success)
    case failure(Failure)
    case demo
}
