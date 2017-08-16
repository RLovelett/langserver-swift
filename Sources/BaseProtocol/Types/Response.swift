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
import os.log

fileprivate let headerSeparator = "\r\n"
fileprivate let headerTerminator = "\r\n\r\n"
fileprivate let pattern = headerTerminator.data(using: .utf8)!
@available(macOS 10.12, *)
private let log = OSLog(subsystem: "me.lovelett.langserver-swift", category: "Response")

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

    public init<C: Collection>(to request: Request, is message: C) where C.Iterator.Element: Encodable {
        switch request {
        case .notification(_, _):
            json = .null
        case .request(id: let id, _, _):
            self = Response(is: .success(message.encode()), for: id)
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

        guard let jsonData = try? JSONSerialization.data(withJSONObject: json.JSONObject()) else {
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

        let response = headerData ?? pattern
        if #available(macOS 10.12, *), let msg = String(bytes: response, encoding: .utf8) {
            os_log("%{public}@", log: log, type: .default, msg)
        }
        return response
    }

}
