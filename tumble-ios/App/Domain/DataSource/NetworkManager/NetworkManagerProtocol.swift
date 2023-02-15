//
//  NetworkManagerProtocol.swift
//  tumble-ios
//
//  Created by Adis Veletanlic on 2023-02-03.
//

import Foundation

protocol NetworkManagerProtocol {
    
    func createRequest<Request: Encodable, Response: Decodable>(authToken: String?, endpoint: Endpoint, method: Method, body: Request?, completion: @escaping (Result<Response, Error>) -> Void)
    
    func get<Response: Decodable>(_ endpoint: Endpoint, authToken: String?, then completion: ((Result<Response, Error>) -> Void)?)
    
    func put<Response: Decodable>(_ endpoint: Endpoint, authToken: String?, then completion: ((Result<Response, Error>) -> Void)?)
    
    func post<Response: Decodable, Request: Encodable>(_ endpoint: Endpoint, authToken: String?, body: Request, then completion: ((Result<Response, Error>) -> Void)?)
}
