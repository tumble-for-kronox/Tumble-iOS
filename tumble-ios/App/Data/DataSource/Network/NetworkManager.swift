//
//  NetworkManager.swift
//  ios-tumble
//
//  Created by Adis Veletanlic on 11/15/22.
//

import Foundation


class NetworkManager: NetworkManagerProtocol {
    
    private let serialQueue = OperationQueue()
    private let encoder = JSONEncoder()
    private let decoder = JSONDecoder()
    private let session: URLSession
    
    init() {
        
        self.serialQueue.maxConcurrentOperationCount = 1
        self.serialQueue.qualityOfService = .userInitiated
        
        let config: URLSessionConfiguration = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = 20
        config.timeoutIntervalForResource = 20
        self.session = URLSession(configuration: config)
    }
    
    
    func createRequest<Request: Encodable, Response: Decodable>(authToken: String?, endpoint: Endpoint, method: Method, body: Request? = nil, completion: @escaping (Result<Response, Error>) -> Void) {
        serialQueue.addOperation {
            let semaphore = DispatchSemaphore(value: 0)
            self.processNetworkRequest(authToken: authToken, endpoint: endpoint, method: method, body: body, completion: { (result: Result<Response, Error>) in
                completion(result)
                semaphore.signal()
            })
            _ = semaphore.wait(timeout: DispatchTime.distantFuture)
        }
    }
    
    
    fileprivate func processNetworkRequest<Request: Encodable, Response: Decodable>(
        authToken: String?,
        endpoint: Endpoint,
        method: Method,
        body: Request? = nil,
        completion: @escaping (Result<Response, Error>) -> Void) {
        
        guard let urlRequest = createUrlRequest(method: method, endpoint: endpoint, authToken: authToken, body: body) else {
            completion(.failure(.internal(reason: "Could not encode request body")))
            return
        }
        
        let networkTask: URLSessionDataTask = createNetworkTask(urlRequest: urlRequest, completion: completion)
        
        networkTask.resume()
    }
    
    fileprivate func createNetworkTask<Response: Decodable>(urlRequest: URLRequest, completion: @escaping (Result<Response, Error>) -> Void) -> URLSessionDataTask {
        return self.session
            .dataTask(with: urlRequest) { data, response, error in
                if let error = error {
                    completion(.failure(.generic(reason: "Could not fetch data: \(error.localizedDescription)")))
                    return
                }
                
                guard let httpUrlResponse = response as? HTTPURLResponse else {
                    completion(.failure(.generic(reason: "Invalid response")))
                    return
                }
                
                guard let data = data else {
                    completion(.failure(.internal(reason: "Data is nil")))
                    return
                }
                
                do {
                    guard !data.isEmpty else {
                        if let result = httpUrlResponse.toHttpResponseObject() as? Response {
                            completion(.success(result))
                            return
                        }
                        completion(.failure(.internal(reason: "Could not convert response to HTTPResponse")))
                        return
                    }
                    let result = try self.decoder.decode(Response.self, from: data)
                    completion(.success(result))
                } catch {
                    completion(.failure(.generic(reason: "Could not decode data: \(error.localizedDescription)")))
                }
            }
    }
    
    fileprivate func createUrlRequest<Request: Encodable>(
        method: Method,
        endpoint: Endpoint,
        authToken: String?,
        body: Request? = nil) -> URLRequest? {
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
                return nil
            }
        }
        return urlRequest
    }
    
    // [HTTP GET]
    func get<Response: Decodable>(
        _ endpoint: Endpoint,
        authToken: String? = nil,
        then completion: ((Result<Response, Error>) -> Void)? = nil
    ) {
        let body: Request.Empty? = nil
        self.createRequest(authToken: authToken, endpoint: endpoint, method: .get, body: body) { result in
            completion?(result)
        }
    }
    
    // [HTTP PUT]
    func put<Response: Decodable>(
        _ endpoint: Endpoint,
        authToken: String? = nil,
        then completion: ((Result<Response, Error>) -> Void)? = nil
    ) {
        let body: Request.Empty? = nil
        self.createRequest(authToken: authToken, endpoint: endpoint, method: .put, body: body) { result in
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
        self.createRequest(authToken: authToken, endpoint: endpoint, method: .post, body: body) { result in
            completion?(result)
        }
    }

}
