//
//  NetworkManager.swift
//  ios-tumble
//
//  Created by Adis Veletanlic on 11/15/22.
//

import Foundation

class NetworkManager: NetworkManagerProtocol {
    
    private let encoder = JSONEncoder()
    private let decoder = JSONDecoder()
    private let session: URLSession
    
    init() {
        let config: URLSessionConfiguration = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = 20
        config.timeoutIntervalForResource = 20
        self.session = URLSession(configuration: config)
    }
    
    
    // Generic network request function handling network logic
    func fetch<Request, Response>(_ endpoint: Endpoint, method: Method = .get, body: Request? = nil,
        then callback: ((Result<Response, Error>) -> Void)? = nil
    ) where Request: Codable, Response: Codable {
        var urlRequest = URLRequest(url: endpoint.url)
        urlRequest.httpMethod = method.rawValue
        
        // If a body is attached to the fetch call, attempt to encode the request body
        if let body = body {
            do {
                urlRequest.httpBody = try encoder.encode(body)
            } catch {
                callback?(.failure(.internal(reason: "Could not encode request body")))
                return
            }
        }
        
        let networkTask = self.session
            .dataTask(with: urlRequest) { data, response, error in
                if let error = error {
                    AppLogger.shared.info("Fetch error: \(error)")
                    callback?(.failure(.generic(reason: "Could not fetch data: \(error.localizedDescription)")))
                    return
                }
                // If data is received and is not null
                if let data = data {
                    do {
                        let result = try self.decoder.decode(Response.self, from: data)
                        callback?(.success(result))
                    } catch {
                        AppLogger.shared.info("Decoding error: \(error)")
                        callback?(.failure(.generic(reason: "Could not decode data: \(error.localizedDescription)")))
                    }
                }
            }
        
        networkTask.resume()
    }
    // [HTTP GET]
    func get<Response>(_ endpoint: Endpoint, then callback: ((Result<Response, Error>) -> Void)? = nil
    ) where Response: Codable {
        let body: Request.Empty? = nil
        fetch(endpoint, method: .get, body: body) { result in
            callback?(result)
        }
    }
    
    // [HTTP PUT]
    func put<Request>(_ endpoint: Endpoint, body: Request, then callback: ((Result<Request, Error>) -> Void)? = nil
    ) where Request: Codable {
        fetch(endpoint, method: .put, body: body) { result in
            callback?(result)
        }
    }
    
    // [HTTP POST]
    func post<Request>(_ endpoint: Endpoint, body: Request, then callback:
                       ((Result<Request, Error>) -> Void)? = nil
    ) where Request: Codable {
        fetch(endpoint, method: .put, body: body) { result in
            callback?(result)
        }
    }
}
