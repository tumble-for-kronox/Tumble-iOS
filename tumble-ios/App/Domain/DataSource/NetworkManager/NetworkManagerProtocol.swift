//
//  NetworkManagerProtocol.swift
//  tumble-ios
//
//  Created by Adis Veletanlic on 2023-02-03.
//

import Foundation

protocol NetworkManagerProtocol {
    
    func get<Response: Decodable>(_ endpoint: Endpoint, sessionToken: String?, then completion: ((Result<Response, Error>) -> Void)?)
    
    func put<Response: Decodable>(_ endpoint: Endpoint, sessionToken: String?, then completion: ((Result<Response, Error>) -> Void)?)
    
    func post<Response: Decodable, Request: Encodable>(_ endpoint: Endpoint, sessionToken: String?, body: Request, then completion: ((Result<Response, Error>) -> Void)?)
}
