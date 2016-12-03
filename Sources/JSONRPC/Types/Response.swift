//
//  Response.swift
//  langserver-swift
//
//  Created by Ryan Lovelett on 11/22/16.
//
//

import Argo
import Foundation
import Ogra

fileprivate let headerSeparator = "\r\n"
fileprivate let headerTerminator = "\r\n\r\n"
fileprivate let pattern = headerTerminator.data(using: .utf8)!

public struct Response {

    let json: JSON

    public init(to request: Request, is message: Encodable) {
        switch request {
        case .notification(method: _, params: _):
            json = .null
        case .request(id: let id, method: _, params: _):
            self = Response(is: .success(message), for: id)
        }
    }

    public init(to request: Request, is error: ServerError) {
        switch request {
        case .notification(method: _, params: _):
            json = .null
        case .request(id: let id, method: _, params: _):
            self = Response(is: .error(error), for: id)
        }
    }

    private init(is result: Result, for id: Request.Identifier) {
        var obj: [String : JSON] = [
            "jsonrpc" : JSON.string("2.0")
        ]

        switch id {
        case .number(let val): obj["id"] = JSON.number(NSNumber(value: val))
        case .string(let val): obj["id"] = JSON.string(val)
        }

        switch result {
        case .success(let result):
            obj["result"] = result.encode()
        case .error(let error):
            obj["error"] = JSON.object([
                "code" : JSON.number(NSNumber(value: error.code)),
                "message" : JSON.string(error.message)
            ])
        }

        json = JSON.object(obj)
    }

    public func data(_ headers: [String : String] = [ : ]) -> Data {
        var mutableHeader = headers

        guard let jsonData = try? JSONSerialization.data(withJSONObject: json.JSONObject(), options: .prettyPrinted) else {
            return pattern
        }

        if !jsonData.isEmpty {
            mutableHeader["Content-Length"] = String(jsonData.count)
        }

        var headerData = mutableHeader.map({ "\($0): \($1)" })
            .joined(separator: headerSeparator)
            .appending(headerTerminator)
            .data(using: .utf8)

        headerData?.append(jsonData)

        return headerData ?? pattern
    }

}
