//
//  APIClient.swift
//  ios-tumble
//
//  Created by Adis Veletanlic on 11/15/22.
//

import Foundation

extension API {
    class Client {
        static let shared = Client()
        private let encoder = JSONEncoder()
        private let decoder = JSONDecoder()
        
        // Generic network request function handling network logic
        func fetch<Request, Response>(_ endpoint: Types.Endpoint, method: Types.Method = .get, body: Request? = nil,
            then callback: ((Result<Response, Types.Error>) -> Void)? = nil
        ) where Request: Codable, Response: Codable {

            var urlRequest = URLRequest(url: endpoint.url)
            urlRequest.httpMethod = method.rawValue
            
            // If a body is attached to the fetch call, encode the request body
            if let body = body {
                do {
                    urlRequest.httpBody = try encoder.encode(body)
                } catch {
                    callback?(.failure(.internal(reason: "Could not encode request body")))
                    return
                }
                
                
                let dataTask = URLSession.shared
                    .dataTask(with: urlRequest) { data, response, error in
                        if let error = error {
                            print("Fetch error: \(error)")
                            callback?(.failure(.generic(reason: "Could not fetch data: \(error.localizedDescription)")))
                        } else {
                            // If data is received and is not null
                            if let data = data {
                                do {
                                    let result = try self.decoder.decode(Response.self, from: data)
                                    callback?(.success(result))
                                } catch {
                                    print("Decoding error: \(error)")
                                    callback?(.failure(.generic(reason: "Could not decode data: \(error.localizedDescription)")))
                                }
                            }
                        }
                    }
                dataTask.resume()
            }
        }
        // [HTTP GET]
        func get<Response>(_ endpoint: Types.Endpoint, then callback: ((Result<Response, Types.Error>) -> Void)? = nil
        ) where Response: Codable {
            let body: Types.Request.Empty? = nil
            fetch(endpoint, method: .get, body: body) { result in
                callback?(result)
            }
        }
        
        // [HTTP PUT]
        func put<Request>(_ endpoint: Types.Endpoint, body: Request, then callback: ((Result<Request, Types.Error>) -> Void)? = nil
        ) where Request: Codable {
            fetch(endpoint, method: .put, body: body) { result in
                callback?(result)
            }
        }
        
        // [HTTP POST]
        func post<Request>(_ endpoint: Types.Endpoint, body: Request, then callback:
                           ((Result<Request, Types.Error>) -> Void)? = nil
        ) where Request: Codable {
            fetch(endpoint, method: .put, body: body) { result in
                callback?(result)
            }
        }
    }
}
