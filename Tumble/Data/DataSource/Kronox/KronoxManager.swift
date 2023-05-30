//
//  NetworkManager.swift
//  ios-tumble
//
//  Created by Adis Veletanlic on 11/15/22.
//

import Foundation

class KronoxManager: KronoxManagerProtocol {
    private let serialQueue = OperationQueue()
    private let urlRequestUtils = NetworkUtilities.shared
    private let session: URLSession
    
    init() {
        serialQueue.maxConcurrentOperationCount = 1
        serialQueue.qualityOfService = .userInitiated
        session = URLSession.shared
    }
    
    func get<NetworkResponse: Decodable>(
        _ endpoint: Endpoint,
        refreshToken: String? = nil
    ) async throws -> NetworkResponse {
        let body: Request.Empty? = nil
        let urlRequest = try makeUrlRequest(method: .get, endpoint: endpoint, refreshToken: refreshToken, body: body)
        return try await fetchRequest(urlRequest: urlRequest)
    }
    
    func put<NetworkResponse : Decodable, Request : Encodable>(
        _ endpoint: Endpoint,
        refreshToken: String? = nil,
        body: Request? = nil
    ) async throws -> NetworkResponse {
        let urlRequest = try makeUrlRequest(method: .put, endpoint: endpoint, refreshToken: refreshToken, body: body)
        return try await fetchRequest(urlRequest: urlRequest)
    }
    
    private func makeUrlRequest<Request : Encodable>(
        method: Method,
        endpoint: Endpoint,
        refreshToken: String?,
        body: Request?
    ) throws -> URLRequest {
        guard let urlRequest = urlRequestUtils.createUrlRequest(
            method: method,
            endpoint: endpoint,
            refreshToken: refreshToken,
            body: body
        ) else {
            throw Error.generic(reason: "Could not create url request")
        }
        return urlRequest
    }
    
    private func fetchRequest<NetworkResponse : Decodable>(urlRequest: URLRequest) async throws -> NetworkResponse {
        let (data, response) = try await session.data(for: urlRequest)
            
        guard let httpResponse = response as? HTTPURLResponse else {
            throw URLError(.badServerResponse)
        }
        
        let statusCode = httpResponse.statusCode
        
        if statusCode == 200 {
            do {
                let decoder = JSONDecoder()
                let decodedData = try decoder.decode(NetworkResponse.self, from: data)
                return decodedData
            } catch {
                if let result = Response.Empty() as? NetworkResponse {
                    return result
                }
            }
        } else if statusCode == 202 {
            if let result = Response.Empty() as? NetworkResponse {
                return result
            }
        }
        throw Error.generic(reason: "Something went wrong")
    }
}
