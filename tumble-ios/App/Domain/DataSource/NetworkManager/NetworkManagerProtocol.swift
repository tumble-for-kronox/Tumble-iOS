//
//  NetworkManagerProtocol.swift
//  tumble-ios
//
//  Created by Adis Veletanlic on 2023-02-03.
//

import Foundation

protocol NetworkManagerProtocol {
    
    func get<NetworkResponse: Decodable>(
        _ endpoint: Endpoint,
        refreshToken: String?,
        then completion: ((Result<NetworkResponse, Response.ErrorMessage>) -> Void)?)
    
    func put<NetworkResponse: Decodable, Request: Encodable>(
        _ endpoint: Endpoint,
        refreshToken: String?,
        body: Request?,
        then completion: ((Result<NetworkResponse, Response.ErrorMessage>) -> Void)?)
    
}
