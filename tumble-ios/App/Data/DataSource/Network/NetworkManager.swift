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
    func get<NetworkResponse: Decodable>(
        _ endpoint: Endpoint,
        refreshToken: String? = nil,
        then completion: ((Result<NetworkResponse, Response.ErrorMessage>) -> Void)? = nil
    ) {
        let body: Request.Empty? = nil
        self.createRequest(refreshToken: refreshToken, endpoint: endpoint, method: .get, body: body) { result in
            completion?(result)
        }
    }
    
    // [HTTP PUT]
    func put<NetworkResponse: Decodable>(
        _ endpoint: Endpoint,
        refreshToken: String? = nil,
        then completion: ((Result<NetworkResponse, Response.ErrorMessage>) -> Void)? = nil
    ) {
        let body: Request.Empty? = nil
        self.createRequest(refreshToken: refreshToken, endpoint: endpoint, method: .put, body: body) { result in
            completion?(result)
        }
    }
    
    // [HTTP POST]
    func post<NetworkResponse: Decodable, Request: Encodable>(
        _ endpoint: Endpoint,
        refreshToken: String? = nil,
        body: Request,
        then completion: ((Result<NetworkResponse, Response.ErrorMessage>) -> Void)? = nil
    ) {
        self.createRequest(refreshToken: refreshToken, endpoint: endpoint, method: .post, body: body) { result in
            completion?(result)
        }
    }
    
    
    
    // Adds network request to serial queue
    fileprivate func createRequest<Request: Encodable, NetworkResponse: Decodable>(
        refreshToken: String?,
        endpoint: Endpoint,
        method: Method,
        body: Request? = nil,
        completion: @escaping (Result<NetworkResponse, Response.ErrorMessage>) -> Void) {
            serialQueue.addOperation {
                let semaphore = DispatchSemaphore(value: 0)
                self.processNetworkRequest(
                    refreshToken: refreshToken,
                    endpoint: endpoint,
                    method: method,
                    body: body,
                    completion: { (result: Result<NetworkResponse, Response.ErrorMessage>) in
                    completion(result)
                    semaphore.signal()
                })
                _ = semaphore.wait(timeout: DispatchTime.distantFuture)
            }
        }
    
    
    // Processes the queued network request, creating a URLSessionDataTask
    fileprivate func processNetworkRequest<Request: Encodable, NetworkResponse: Decodable>(
        refreshToken: String?,
        endpoint: Endpoint,
        method: Method,
        body: Request? = nil,
        completion: @escaping (Result<NetworkResponse, Response.ErrorMessage>) -> Void) {
            guard let urlRequest = createUrlRequest(method: method, endpoint: endpoint, refreshToken: refreshToken, body: body) else {
                completion(.failure(Response.ErrorMessage(message: "Something went wrong on our end")))
                return
            }
            
            let networkTask: URLSessionDataTask = createUrlSessionDataTask(urlRequest: urlRequest, completion: completion)
            networkTask.resume()
        }
    
    
    // Creates a URLSessionDataTask that handles all possible response cases
    fileprivate func createUrlSessionDataTask<NetworkResponse: Decodable>(
        urlRequest: URLRequest,
        completion: @escaping (Result<NetworkResponse, Response.ErrorMessage>) -> Void) -> URLSessionDataTask {
            return self.session
                .dataTask(with: urlRequest) { data, response, error in
                    if let _ = error {
                        completion(.failure(Response.ErrorMessage(message: "Could not contact the server")))
                        return
                    }
                    
                    guard let httpUrlNetworkResponse = response as? HTTPURLResponse else {
                        completion(.failure(Response.ErrorMessage(message: "Could not contact the server")))
                        return
                    }
                    
                    guard let data = data else {
                        completion(.failure(Response.ErrorMessage(message: "Something went wrong on our end")))
                        return
                    }
                    
                    do {
                        if httpUrlNetworkResponse.statusCode > 200 {
                            completion(.failure(Response.ErrorMessage(
                                message: "Something went wrong on our end",
                                statusCode: httpUrlNetworkResponse.statusCode)
                            ))
                            return
                        }
                        let result = try self.decoder.decode(NetworkResponse.self, from: data)
                        completion(.success(result))
                        
                    } catch (let error) {
                        do {
                            AppLogger.shared.critical("Failed to decode response to object \(NetworkResponse.self). Error: \(error)", source: "NetworkManager")
                            // Attempt to decode object into server response error message, if request fails
                            let result = try self.decoder.decode(Response.ErrorMessage.self, from: data)
                            completion(.failure(result))
                        } catch {
                            completion(.failure(Response.ErrorMessage(message: "Something went wrong on our end")))
                        }
                    }
                }
        }
    
    
    // Creates a URLRequest with necessary headers and body
    // based on method type
    fileprivate func createUrlRequest<Request: Encodable>(
        method: Method,
        endpoint: Endpoint,
        refreshToken: String?,
        body: Request? = nil) -> URLRequest? {
        
            var urlRequest = URLRequest(url: endpoint.url)
            urlRequest.httpMethod = method.rawValue
            
            urlRequest.setValue(refreshToken, forHTTPHeaderField: "X-auth-token")
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
