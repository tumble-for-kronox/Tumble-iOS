//
//  AuthInterceptor.swift
//  tumble-ios
//
//  Created by Adis Veletanlic on 2023-03-23.
//

import Foundation

class AuthInterceptor: NSObject, URLSessionDelegate {
    
    private let refreshToken: String
    
    init(refreshToken: String) {
        self.refreshToken = refreshToken
    }
    
    func urlSession(_ session: URLSession, task: URLSessionTask, willPerformHTTPRedirection response: HTTPURLResponse, newRequest request: URLRequest, completionHandler: @escaping (URLRequest?) -> Void) {
        var request = request
        request.addValue(self.refreshToken, forHTTPHeaderField: "X-Auth-Token")
        completionHandler(request)
    }
}
