//
//  NetworkManagerProtocol.swift
//  Tumble
//
//  Created by Adis Veletanlic on 2023-02-03.
//

import Foundation

protocol KronoxManagerProtocol {
    func get<NetworkResponse: Decodable>(
        _ endpoint: Endpoint,
        refreshToken: String?
    ) async throws -> NetworkResponse
    
    func put<NetworkResponse : Decodable, Request : Encodable>(
        _ endpoint: Endpoint,
        refreshToken: String?,
        body: Request?
    ) async throws -> NetworkResponse
}
