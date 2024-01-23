//
//  URLRequestExtension.swift
//  Tumble
//
//  Created by Adis Veletanlic on 3/23/23.
//

import Foundation

struct NetworkUtilities {
    static let shared = NetworkUtilities()
    private let encoder = JSONEncoder()
    
    func createUrlRequest<Request: Encodable>(
        method: Method,
        endpoint: Endpoint,
        refreshToken: String? = nil,
        sessionToken: String? = nil,
        body: Request? = nil
    ) throws -> URLRequest {
        var urlRequest = URLRequest(url: endpoint.url)
        urlRequest.httpMethod = method.rawValue

        try setHeaders(for: &urlRequest, refreshToken: refreshToken, sessionToken: sessionToken)
        try setRequestBody(for: &urlRequest, with: body)

        return urlRequest
    }

    private func setHeaders(
        for urlRequest: inout URLRequest,
        refreshToken: String?,
        sessionToken: String?
    ) throws {
        urlRequest.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
        urlRequest.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Accept")

        urlRequest.setValue(refreshToken, forHTTPHeaderField: "X-auth-token")
        urlRequest.setValue(sessionToken, forHTTPHeaderField: "X-session-token")
    }

    private func setRequestBody<Request: Encodable>(
        for urlRequest: inout URLRequest,
        with body: Request?
    ) throws {
        guard let body = body else { return }
        let encoder = JSONEncoder()
        urlRequest.httpBody = try encoder.encode(body)
    }
}
