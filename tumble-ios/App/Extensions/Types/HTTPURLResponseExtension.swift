//
//  HTTPURLResponseExtension.swift
//  tumble-ios
//
//  Created by Adis Veletanlic on 2023-02-15.
//

import Foundation

extension HTTPURLResponse {
    func toHttpResponseObject() -> Response.HTTPResponse {
        if let headers = self.allHeaderFields as? [String : Any] {
            let contentLength = headers["Content-Length"] as? Int
            let date = headers["Date"] as? String
            let server = headers["Server"] as? String
            let httpResponseObject = Response.HTTPResponse(
                url: self.url?.absoluteString,
                statusCode: self.statusCode,
                headers: Response.Headers(contentLength: contentLength ?? 0, date: date ?? "", server: server ?? ""))
            return httpResponseObject
        }
        let httpResponseObject = Response.HTTPResponse(
            url: self.url?.absoluteString,
            statusCode: self.statusCode,
            headers: nil)
        return httpResponseObject
    }
}
