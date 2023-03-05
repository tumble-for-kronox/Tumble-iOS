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
    private var MAX_CONSECUTIVE_ATTEMPTS: Int = 4
    
    init() {
        
        self.serialQueue.maxConcurrentOperationCount = 1
        self.serialQueue.qualityOfService = .userInitiated
        
        let config: URLSessionConfiguration = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = 20
        config.timeoutIntervalForResource = 20
        self.session = URLSession(configuration: config)
    }
    
    // [HTTP GET]
    func get<Response: Decodable>(
        _ endpoint: Endpoint,
        sessionToken: String? = nil,
        then completion: ((Result<Response, Error>) -> Void)? = nil
    ) {
        let body: Request.Empty? = nil
        self.createRequest(sessionToken: sessionToken, endpoint: endpoint, method: .get, body: body) { result in
            completion?(result)
        }
    }
    
    // [HTTP PUT]
    func put<Response: Decodable>(
        _ endpoint: Endpoint,
        sessionToken: String? = nil,
        then completion: ((Result<Response, Error>) -> Void)? = nil
    ) {
        let body: Request.Empty? = nil
        self.createRequest(sessionToken: sessionToken, endpoint: endpoint, method: .put, body: body) { result in
            completion?(result)
        }
    }
    
    // [HTTP POST]
    func post<Response: Decodable, Request: Encodable>(
        _ endpoint: Endpoint,
        sessionToken: String? = nil,
        body: Request,
        then completion: ((Result<Response, Error>) -> Void)? = nil
    ) {
        self.createRequest(sessionToken: sessionToken, endpoint: endpoint, method: .post, body: body) { result in
            completion?(result)
        }
    }
    
    
    
    // Adds network request to serial queue
    fileprivate func createRequest<Request: Encodable, Response: Decodable>(
        sessionToken: String?,
        endpoint: Endpoint,
        method: Method,
        body: Request? = nil,
        completion: @escaping (Result<Response, Error>) -> Void) {
            serialQueue.addOperation {
                let semaphore = DispatchSemaphore(value: 0)
                self.processNetworkRequest(sessionToken: sessionToken, endpoint: endpoint, method: method, body: body, completion: { (result: Result<Response, Error>) in
                    completion(result)
                    semaphore.signal()
                })
                _ = semaphore.wait(timeout: DispatchTime.distantFuture)
            }
        }
    
    
    // Processes the queued network request, creating a URLSessionDataTask
    fileprivate func processNetworkRequest<Request: Encodable, Response: Decodable>(
        sessionToken: String?,
        endpoint: Endpoint,
        method: Method,
        body: Request? = nil,
        completion: @escaping (Result<Response, Error>) -> Void) {
            guard let urlRequest = createUrlRequest(method: method, endpoint: endpoint, sessionToken: sessionToken, body: body) else {
                completion(.failure(.internal(reason: "Could not encode request body")))
                return
            }
            
            let networkTask: URLSessionDataTask = createUrlSessionDataTask(urlRequest: urlRequest, completion: completion)
            networkTask.resume()
        }
    
    
    // Creates a URLSessionDataTask that handles all possible response cases
    fileprivate func createUrlSessionDataTask<Response: Decodable>(
        urlRequest: URLRequest,
        completion: @escaping (Result<Response, Error>) -> Void) -> URLSessionDataTask {
            return self.session
                .dataTask(with: urlRequest) { data, response, error in
                    if let error = error {
                        completion(.failure(.generic(reason: "Could not fetch data: \(error)")))
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
                                if httpUrlResponse.statusCode > 200 {
                                    completion(.failure(.generic(reason: "ERROR STATUS: RESPONSE -> \(httpUrlResponse.statusCode)")))
                                    return
                                }
                                AppLogger.shared.info("SUCCESS STATUS: RESPONSE -> \(httpUrlResponse.statusCode)")
                                completion(.success(result))
                                return
                            }
                            completion(.failure(.internal(reason: "Could not convert response to HTTPResponse")))
                            return
                        }
                        let result = try self.decoder.decode(Response.self, from: data)
                        completion(.success(result))
                    } catch {
                        completion(.failure(.generic(reason: "Could not decode data: \(error)")))
                    }
                }
        }
    
    
    // Creates a URLRequest with necessary headers and body
    // based on method type
    fileprivate func createUrlRequest<Request: Encodable>(
        method: Method,
        endpoint: Endpoint,
        sessionToken: String?,
        body: Request? = nil) -> URLRequest? {
        
            var urlRequest = URLRequest(url: endpoint.url)
            urlRequest.httpMethod = method.rawValue
            
            urlRequest.setValue(sessionToken, forHTTPHeaderField: "X-auth-token")
            urlRequest.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
            urlRequest.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Accept")
            
            // If a body is attached to the fetch call,
            // attempt to encode the request body
            if let body = body {
                do {
                    urlRequest.httpBody = try encoder.encode(body)
                } catch {
                    return nil
                }
            }
            return urlRequest
        }
}
