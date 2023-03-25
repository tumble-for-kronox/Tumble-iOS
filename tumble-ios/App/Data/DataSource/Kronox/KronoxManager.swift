//
//  NetworkManager.swift
//  ios-tumble
//
//  Created by Adis Veletanlic on 11/15/22.
//

import Foundation


class KronoxManager: KronoxManagerProtocol {
    
    private let serialQueue = OperationQueue()
    private let encoder = JSONEncoder.shared
    private let decoder = JSONDecoder.shared
    private let urlRequestUtils = URLRequestUtils.shared
    private let session: URLSession
    
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
    func put<NetworkResponse: Decodable, Request: Encodable>(
        _ endpoint: Endpoint,
        refreshToken: String? = nil,
        body: Request? = nil,
        then completion: ((Result<NetworkResponse, Response.ErrorMessage>) -> Void)?) {
        self.createRequest(refreshToken: refreshToken, endpoint: endpoint, method: .put, body: body) { result in
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
            guard let urlRequest = urlRequestUtils.createUrlRequest(method: method, endpoint: endpoint, refreshToken: refreshToken, body: body) else {
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
                    if let error = error {
                        completion(.failure(Response.ErrorMessage(message: "Could not contact the server: \(error)")))
                        return
                    }
                    if let statusCode = (response as? HTTPURLResponse)?.statusCode {
                        switch statusCode {
                        case 200:
                            guard let data = data else {
                                completion(.failure(Response.ErrorMessage(message: "Failed to retrieve data", statusCode: statusCode)))
                                return
                            }
                            do {
                                let result = try self.decoder.decode(NetworkResponse.self, from: data)
                                completion(.success(result))
                            } catch (let error) {
                                AppLogger.shared.critical("Failed to decode response to object \(NetworkResponse.self). Attempting to parse as empty obejct since status was 200. Error: \(error)",
                                  source: "NetworkManager")
                                if let result = Response.Empty() as? NetworkResponse {
                                    completion(.success(result))
                                    return
                                }
                                completion(.failure(Response.ErrorMessage(message: "Unable to convert empty response object to \(NetworkResponse.self)", statusCode: statusCode)))
                            }
                        default:
                            completion(.failure(Response.ErrorMessage(message: "Something went wrong", statusCode: statusCode)))
                        }
                    } else {
                        completion(.failure(Response.ErrorMessage(message: "Did not receive valid HTTP response")))
                    }
                }
        }
}
