//
//  Request.swift
//  langserver-swift
//
//  Created by Ryan Lovelett on 11/22/16.
//
//

import Argo
import Curry
import Foundation
import Runes
#if os(macOS) || os(iOS) || os(watchOS) || os(tvOS)
import os.log

private let log = OSLog(subsystem: "me.lovelett.langserver-swift", category: "Request")
#endif

/// A JSON-RPC
public enum Request {

    case request(id: Identifier, method: String, params: JSON)

    /// A Notification is a `Request` object without an "id" member. A `Request` object that is a
    /// Notification signifies the Client's lack of interest in the corresponding `Response` object,
    /// and as such no `Response` object needs to be returned to the client.
    ///
    /// The Server **MUST NOT** reply to a Notification, including those that are within a batch
    /// request.
    case notification(method: String, params: JSON)

    /// An identifier established by the Client that **MUST** contain a `String`, `Int`, or `null`
    /// value _if included_.
    ///
    /// If it is not included it is assumed to be a notification.
    ///
    /// The value **MUST** not be `null` and numbers **MUST NOT** contain fractional parts.
    ///
    /// - Remark: This is a change from the 2.0 spec, `null` was acceptable. Though strongly
    /// encouraged against. Likewise, fractional numeric identifiers.
    ///
    /// - string: An identifier established by the Client that is a `String`.
    /// - number: An identifier established by the Client that is a `Int`.
    public enum Identifier {
        case string(String)
        case number(Int)
    }

    /// A String containing the name of the method to be invoked. Method names that begin with the
    /// word rpc followed by a period character (U+002E or ASCII 46) are reserved for rpc-internal
    /// methods and extensions and MUST NOT be used for anything else.
    public var method: String {
        switch self {
        case .request(id: _, method: let m, params: _):
            return m
        case .notification(method: let m, params: _):
            return m
        }
    }

    /// An identifier established by the Client. If it is not present, e.g., `Optional.none`, the
    /// request is assumed to be a notification from the Client.
    public var id: Identifier? {
        switch self {
        case .request(id: let i, method: _, params: _):
            return i
        case .notification(method: _, params: _):
            return .none
        }
    }

    private var params: JSON {
        switch self {
        case .notification(method: _, params: let json):
            return json
        case .request(id: _, method: _, params: let json):
            return json
        }
    }

    public init(_ data: Data) throws {
        guard let serialized = try? JSONSerialization.jsonObject(with: data, options: []) else {
            throw PredefinedError.parse
        }

        #if os(macOS) || os(iOS) || os(watchOS) || os(tvOS)
            os_log("%{public}@", log: log, type: .default, String(bytes: data, encoding: .utf8)!)
        #endif

        let json = JSON(serialized)

        let dMethod: Decoded<String> = json["method"]
        let dId: Decoded<Identifier> = json["id"]
        // A Structured value that holds the parameter values to be used during the invocation of
        // the method. This member MAY be omitted.
        let dParams: Decoded<JSON> = json["params"] <|> pure(.null)

        switch (dMethod, dId, dParams) {
        case (.success(let m), .success(let i), .success(let j)):
            self = .request(id: i, method: m, params: j)
        case (.success(let m), _, .success(let j)):
            self = .notification(method: m, params: j)
        default:
            throw PredefinedError.invalidRequest
        }
    }

    public func parse<T: Argo.Decodable>() throws -> T where T.DecodedType == T {
        switch T.decode(params) {
        case .success(let p):
            return p
        case .failure(_):
            throw PredefinedError.invalidParams
        }
    }
}

extension Request.Identifier : Argo.Decodable {

    public static func decode(_ json: JSON) -> Decoded<Request.Identifier> {
        switch json {
        case .number(let x):
            return .success(.number(x.intValue))
        case .string(let s):
            return .success(.string(s))
        default:
            return .typeMismatch(expected: "String or Number", actual: json)
        }
    }

}

extension Request.Identifier : Equatable {

    /// Returns a Boolean value indicating whether two values are equal.
    ///
    /// Equality is the inverse of inequality. For any values `a` and `b`,
    /// `a == b` implies that `a != b` is `false`.
    ///
    /// - Parameters:
    ///   - lhs: A value to compare.
    ///   - rhs: Another value to compare.
    public static func ==(lhs: Request.Identifier, rhs: Request.Identifier) -> Bool {
        switch (lhs, rhs) {
        case (.string(let lhss), .string(let rhss)) where lhss == rhss:
            return true
        case (.number(let lhsn), .number(let rhsn)) where lhsn == rhsn:
            return true
        default:
            return false
        }
    }

}
