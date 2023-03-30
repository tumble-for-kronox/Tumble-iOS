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
        self.session = URLSession.shared
    }
    
    // [HTTP GET]
    func get<NetworkResponse: Decodable>(
        _ endpoint: Endpoint,
        refreshToken: String? = nil,
        then completion: ((Result<NetworkResponse, Response.ErrorMessage>) -> Void)? = nil
    ) -> URLSessionDataTask? {
        let body: Request.Empty? = nil
        return self.createRequest(refreshToken: refreshToken, endpoint: endpoint, method: .get, body: body) { result in
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
        return self.createRequest(refreshToken: refreshToken, endpoint: endpoint, method: .put, body: body) { result in
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
                body: body)
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
        
        let task = session.dataTask(with: urlRequest) { [unowned self] data, response, error in
            guard let httpResponse = response as? HTTPURLResponse else {
                completion(.failure(Response.ErrorMessage(message: "Did not receive valid HTTP response")))
                return
            }
            
            guard let data = data else {
                completion(.failure(Response.ErrorMessage(message: "Failed to retrieve data", statusCode: httpResponse.statusCode)))
                return
            }
            
            switch httpResponse.statusCode {
            case 200:
                do {
                    let result = try self.decoder.decode(NetworkResponse.self, from: data)
                    completion(.success(result))
                } catch let error {
                    AppLogger.shared.critical("Failed to decode response to object \(NetworkResponse.self). Attempting to parse as empty object since status was 200. Error: \(error)",
                                              source: "NetworkManager")
                    if let result = Response.Empty() as? NetworkResponse {
                        completion(.success(result))
                    } else {
                        completion(.failure(Response.ErrorMessage(message: "Unable to convert empty response object to \(NetworkResponse.self)", statusCode: httpResponse.statusCode)))
                    }
                }
            case 202:
                // Return an empty object that conforms to the expected type of NetworkResponse
                if let result = Response.Empty() as? NetworkResponse {
                    completion(.success(result))
                } else {
                    completion(.failure(Response.ErrorMessage(message: "Unable to convert empty response object to \(NetworkResponse.self)", statusCode: httpResponse.statusCode)))
                }
            case 400:
                do {
                    let result = try self.decoder.decode(Response.ErrorMessage.self, from: data)
                    completion(.failure(result))
                } catch {
                    AppLogger.shared.critical("Failed to decode response to object \(Response.ErrorMessage.self)",
                                              source: "NetworkManager")
                    completion(.failure(Response.ErrorMessage(message: "Unable to convert empty response object to \(NetworkResponse.self)", statusCode: httpResponse.statusCode)))
                }
            default:
                completion(.failure(Response.ErrorMessage(message: "Something went wrong", statusCode: httpResponse.statusCode)))
            }
        }
        
        return task
    }

}
