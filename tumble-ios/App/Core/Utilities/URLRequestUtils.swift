//
//  URLRequestExtension.swift
//  tumble-ios
//
//  Created by Adis Veletanlic on 3/23/23.
//

import Foundation

extension JSONEncoder {
    static let shared: JSONEncoder = JSONEncoder()
}

extension JSONDecoder {
    static let shared: JSONDecoder = JSONDecoder()
}

struct URLRequestUtils {
    
    static let shared = URLRequestUtils()
    
    /// Creates a URLRequest with necessary headers and body
    /// based on method type
    func createUrlRequest<Request: Encodable>(
        method: Method,
        endpoint: Endpoint,
        refreshToken: String? = nil,
        body: Request? = nil) -> URLRequest? {
            
            var urlRequest = URLRequest(url: endpoint.url)
            urlRequest.httpMethod = method.rawValue
            
            urlRequest.setValue(refreshToken, forHTTPHeaderField: "X-auth-token")
            urlRequest.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
            urlRequest.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Accept")
            
            if let body = body {
                do {
                    urlRequest.httpBody = try JSONEncoder.shared.encode(body)
                } catch {
                    return nil
                }
            }
            return urlRequest
        }
}
