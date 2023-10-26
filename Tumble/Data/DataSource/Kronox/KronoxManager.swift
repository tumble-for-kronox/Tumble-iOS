//
//  NetworkManager.swift
//  ios-tumble
//
//  Created by Adis Veletanlic on 11/15/22.
//

import Foundation

enum KronoxManagerError: LocalizedError {
    case generic(String)
    case badServerResponse
    case wrongStatusCode
    case emptyResponse
    case decodingError
    case noInternetConnection
    
    var errorDescription: String? {
        switch self {
        case .generic(let reason):
            return reason
        case .badServerResponse, .wrongStatusCode:
            return NSLocalizedString("Bad server response.", comment: "")
        case .emptyResponse:
            return NSLocalizedString("The server seems to be offline", comment: "")
        case .decodingError:
            return NSLocalizedString("Something went wrong on our end", comment: "")
        case .noInternetConnection:
            return NSLocalizedString("Not connected to the internet.", comment: "")
        }
    }
}


class KronoxManager {
    private let urlRequestUtils = NetworkUtilities.shared
    private let session = URLSession.shared
    private let decoder = JSONDecoder()
    
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
            throw KronoxManagerError.decodingError
        }
        return urlRequest
    }
    
    private func fetchRequest<NetworkResponse : Decodable>(urlRequest: URLRequest) async throws -> NetworkResponse {
        do {
            let (data, response) = try await session.data(for: urlRequest)
                
            guard let httpResponse = response as? HTTPURLResponse else {
                throw KronoxManagerError.badServerResponse
            }
            
            let statusCode = httpResponse.statusCode
            
            if statusCode == 200 {
                do {
                    let decodedData = try decoder.decode(NetworkResponse.self, from: data)
                    return decodedData
                } catch {
                    if let result = Response.Empty() as? NetworkResponse {
                        return result
                    } else {
                        throw KronoxManagerError.decodingError
                    }
                }
            } else if statusCode == 202 {
                if let result = Response.Empty() as? NetworkResponse {
                    return result
                } else {
                    throw KronoxManagerError.emptyResponse
                }
            } else {
                throw KronoxManagerError.wrongStatusCode
            }
        } catch {
            if let urlError = error as? URLError {
                    switch urlError.code {
                    case .notConnectedToInternet, .networkConnectionLost, .dataNotAllowed:
                        throw KronoxManagerError.noInternetConnection
                    default:
                        throw KronoxManagerError.decodingError
                    }
                } else {
                    throw KronoxManagerError.decodingError
                }
        }
    }

}
