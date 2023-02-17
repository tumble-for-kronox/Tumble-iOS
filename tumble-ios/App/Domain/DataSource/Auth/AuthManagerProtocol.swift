//
//  AuthManagerProtocol.swift
//  tumble-ios
//
//  Created by Adis Veletanlic on 2023-02-17.
//

import Foundation

protocol AuthManagerProtocol {
    
    func autoLoginUser(completionHandler: @escaping (Result<TumbleUser, Error>) -> Void) -> Void
    
    func loginUser(user: Request.KronoxUserLogin, completionHandler: @escaping (Result<TumbleUser, Error>) -> Void)
    
    func logOutUser(completionHandler: ((Result<Int, Error>) -> Void)?)
}
