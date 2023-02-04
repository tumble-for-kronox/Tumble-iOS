//
//  NetworkManagerProtocol.swift
//  tumble-ios
//
//  Created by Adis Veletanlic on 2023-02-03.
//

import Foundation

protocol NetworkManagerProtocol {
    
    func fetch<Request, Response>(_ endpoint: Endpoint, method: Method, body: Request?,
        then callback: ((Result<Response, NetworkError>) -> Void)?) where Request: Codable, Response: Codable
    
    func get<Response>(_ endpoint: Endpoint, then callback: ((Result<Response, NetworkError>) -> Void)?) where Response: Codable
    
    func put<Request>(_ endpoint: Endpoint, body: Request, then callback: ((Result<Request, NetworkError>) -> Void)?) where Request: Codable
    
    func post<Request>(_ endpoint: Endpoint, body: Request, then callback:
                       ((Result<Request, NetworkError>) -> Void)?) where Request: Codable
}
