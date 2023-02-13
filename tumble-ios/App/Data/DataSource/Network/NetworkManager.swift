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
    
    
    func request<Request: Encodable, Response: Decodable>(authToken: String?, endpoint: Endpoint, method: Method, body: Request? = nil, completion: @escaping (Result<Response, Error>) -> Void) {
        
        var urlRequest = URLRequest(url: endpoint.url)
        urlRequest.httpMethod = method.rawValue
        
        urlRequest.setValue(authToken, forHTTPHeaderField: "X-auth-token")
        urlRequest.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
        urlRequest.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Accept")
        
        // If a body is attached to the fetch call, attempt to encode the request body
        if let body = body {
            do {
                urlRequest.httpBody = try encoder.encode(body)
            } catch {
                completion(.failure(.internal(reason: "Could not encode request body")))
                return
            }
        }
        AppLogger.shared.info("URL -> \(String(describing: urlRequest.url))")
        let networkTask = self.session
            .dataTask(with: urlRequest) { data, response, error in
                AppLogger.shared.info("Status code \((response as! HTTPURLResponse).statusCode)")
                if let error = error {
                    AppLogger.shared.info("Fetch error: \(error)")
                    completion(.failure(.generic(reason: "Could not fetch data: \(error.localizedDescription)")))
                    return
                }
                // If data is received and is not null
                if let data = data {
                    do {
                        AppLogger.shared.info("\(data)")
                        let result = try self.decoder.decode(Response.self, from: data)
                        completion(.success(result))
                    } catch {
                        AppLogger.shared.info("Decoding error: \(error)")
                        completion(.failure(.generic(reason: "Could not decode data: \(error.localizedDescription)")))
                    }
                }
            }
        
        networkTask.resume()
    }
    
    // [HTTP GET]
    func get<Response: Decodable>(
        _ endpoint: Endpoint,
        authToken: String?,
        then completion: ((Result<Response, Error>) -> Void)? = nil
    ) {
        let body: Request.Empty? = nil
        self.request(authToken: authToken, endpoint: endpoint, method: .get, body: body) { result in
            completion?(result)
        }
    }
    
    // [HTTP PUT]
    func put<Response: Decodable, Request: Encodable>(
        _ endpoint: Endpoint,
        authToken: String?,
        body: Request,
        then completion: ((Result<Response, Error>) -> Void)? = nil
    ) {
        self.request(authToken: authToken, endpoint: endpoint, method: .put, body: body) { result in
                completion?(result)
            }
    }
    
    // [HTTP POST]
    func post<Response: Decodable, Request: Encodable>(
        _ endpoint: Endpoint,
        authToken: String?,
        body: Request,
        then completion: ((Result<Response, Error>) -> Void)? = nil
    ) {
        self.request(authToken: authToken, endpoint: endpoint, method: .post, body: body) { result in
            completion?(result)
        }
    }
}
