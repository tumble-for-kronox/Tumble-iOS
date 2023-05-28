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
            method: .get,
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
            let decoder = JSONDecoder()
            let decodedData = try decoder.decode(NetworkResponse.self, from: data)
            
            return decodedData
        } else if statusCode == 202 {
            if let result = Response.Empty() as? NetworkResponse {
                return result
            }
        }
        throw Error.generic(reason: "Something went wrong")
    }

    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    // [HTTP GET]
    func get<NetworkResponse: Decodable>(
        _ endpoint: Endpoint,
        refreshToken: String? = nil,
        then completion: ((Result<NetworkResponse, Response.ErrorMessage>) -> Void)? = nil
    ) -> URLSessionDataTask? {
        let body: Request.Empty? = nil
        return createRequest(refreshToken: refreshToken, endpoint: endpoint, method: .get, body: body) { result in
            completion?(result)
        }
    }
    
    // [HTTP PUT]
    func put<NetworkResponse: Decodable, Request: Encodable>(
        _ endpoint: Endpoint,
        refreshToken: String? = nil,
        body: Request? = nil,
        then completion: ((Result<NetworkResponse, Response.ErrorMessage>) -> Void)? = nil
    ) -> URLSessionDataTask? {
        return createRequest(refreshToken: refreshToken, endpoint: endpoint, method: .put, body: body) { result in
            completion?(result)
        }
    }
    
    // Adds network request to serial queue
    fileprivate func createRequest<Request: Encodable, NetworkResponse: Decodable>(
        refreshToken: String?,
        endpoint: Endpoint,
        method: Method,
        body: Request? = nil,
        completion: @escaping (Result<NetworkResponse, Response.ErrorMessage>) -> Void
    ) -> URLSessionDataTask? {
        guard let urlRequest = urlRequestUtils.createUrlRequest(
            method: method,
            endpoint: endpoint,
            refreshToken: refreshToken,
            body: body
        )
        else {
            completion(.failure(Response.ErrorMessage(message: "Something went wrong on our end")))
            return nil
        }
        let networkTask: URLSessionDataTask = createUrlSessionDataTask(
            urlRequest: urlRequest,
            completion: completion
        )
        networkTask.resume()
        return networkTask
    }
    
    // Creates a URLSessionDataTask that handles all possible response cases
    fileprivate func createUrlSessionDataTask<NetworkResponse: Decodable>(
        urlRequest: URLRequest,
        completion: @escaping (Result<NetworkResponse, Response.ErrorMessage>) -> Void
    ) -> URLSessionDataTask {
        let task = session.dataTask(with: urlRequest) { data, response, _ in
            guard let httpResponse = response as? HTTPURLResponse else {
                DispatchQueue.main.async {
                    completion(.failure(Response.ErrorMessage(message: "Did not receive valid HTTP response")))
                }
                return
            }
            
            guard let data = data else {
                DispatchQueue.main.async {
                    completion(.failure(Response.ErrorMessage(message: "Failed to retrieve data", statusCode: httpResponse.statusCode)))
                }
                return
            }
            
            let decoder = JSONDecoder()
            
            switch httpResponse.statusCode {
            case 200:
                do {
                    let result = try decoder.decode(NetworkResponse.self, from: data)
                    DispatchQueue.main.async {
                        completion(.success(result))
                    }
                } catch (let failure) {
                    AppLogger.shared.critical("Failed to decode response to object \(NetworkResponse.self). Attempting to parse as empty object since status was 200. Error: \(failure)",
                                              source: "NetworkManager")
                    if let result = Response.Empty() as? NetworkResponse {
                        DispatchQueue.main.async {
                            completion(.success(result))
                        }
                    } else {
                        DispatchQueue.main.async {
                            completion(.failure(Response.ErrorMessage(message: "Unable to convert empty response object to \(NetworkResponse.self)", statusCode: httpResponse.statusCode)))
                        }
                    }
                }
            case 202:
                // Return an empty object that conforms to the expected type of NetworkResponse
                if let result = Response.Empty() as? NetworkResponse {
                    DispatchQueue.main.async {
                        completion(.success(result))
                    }
                } else {
                    DispatchQueue.main.async {
                        completion(.failure(Response.ErrorMessage(message: "Unable to convert empty response object to \(NetworkResponse.self)", statusCode: httpResponse.statusCode)))
                    }
                }
            case 400:
                do {
                    let result = try decoder.decode(Response.ErrorMessage.self, from: data)
                    DispatchQueue.main.async {
                        completion(.failure(result))
                    }
                } catch {
                    AppLogger.shared.critical("Failed to decode response to object \(Response.ErrorMessage.self)",
                                              source: "NetworkManager")
                    DispatchQueue.main.async {
                        completion(.failure(Response.ErrorMessage(message: "Unable to convert empty response object to \(NetworkResponse.self)", statusCode: httpResponse.statusCode)))
                    }
                }
            default:
                DispatchQueue.main.async {
                    completion(.failure(Response.ErrorMessage(message: "Something went wrong", statusCode: httpResponse.statusCode)))
                }
            }
        }
        
        return task
    }
}
