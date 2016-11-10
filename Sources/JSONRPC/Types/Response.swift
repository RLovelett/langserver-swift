//
//  Response.swift
//  langserver-swift
//
//  Created by Ryan Lovelett on 11/22/16.
//
//

import Foundation

fileprivate let headerSeparator = "\r\n"
fileprivate let headerTerminator = "\r\n\r\n"
fileprivate let pattern = headerTerminator.data(using: .utf8)!

public struct Response {

    let json: [ String : Any ]

    public init(is message: Messageable, for id: Request.Identifier = .null) {
        self = Response(is: .success(message), for: id)
    }

    public init(is error: ServerError, for id: Request.Identifier = .null) {
        self = Response(is: .error(error), for: id)
    }

    init(is result: Result, for id: Request.Identifier = .null) {
        var obj: [String : Any] = [
            "jsonrpc" : "2.0"
        ]

        switch id {
        case .number(let val): obj["id"] = val
        case .string(let val): obj["id"] = val
        case .null: obj["id"] = NSNull()
        }

        switch result {
        case .success(let result):
            switch result.message {
            case .some(let r): obj["result"] = r
            case .none: obj["result"] = [:]
            }
        case .error(let error):
            obj["error"] = [
                "code" : error.code,
                "message" : error.message
            ]
        }

        json = obj
    }

    public func data(_ headers: [String : String] = [ : ]) -> Data {
        var mutableHeader = headers

        guard let jsonData = try? JSONSerialization.data(withJSONObject: json, options: .prettyPrinted) else {
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
