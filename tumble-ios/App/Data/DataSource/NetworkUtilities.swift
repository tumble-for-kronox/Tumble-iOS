//
//  URLRequestExtension.swift
//  tumble-ios
//
//  Created by Adis Veletanlic on 3/23/23.
//

import Foundation

struct NetworkUtilities {
    
    static let shared = NetworkUtilities()
    
    /// Creates a URLRequest with necessary headers and body
    /// based on method type
    func createUrlRequest<Request: Encodable>(
        method: Method,
        endpoint: Endpoint,
        refreshToken: String? = nil,
        body: Request? = nil) -> URLRequest? {
            
            let encoder = JSONEncoder()
            var urlRequest = URLRequest(url: endpoint.url)
            urlRequest.httpMethod = method.rawValue
            
            urlRequest.setValue(refreshToken, forHTTPHeaderField: "X-auth-token")
            urlRequest.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
            urlRequest.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Accept")
            
            if let body = body {
                do {
                    urlRequest.httpBody = try encoder.encode(body)
                } catch {
                    return nil
                }
            }
            return urlRequest
        }
    
    /// Overload function in case no body is given,
    /// as in for example GET requests
    func createUrlRequest(
        method: Method,
        endpoint: Endpoint,
        refreshToken: String? = nil
    ) -> URLRequest? {
        return createUrlRequest(method: method, endpoint: endpoint, refreshToken: refreshToken, body: Optional<String>.none)
    }
}
