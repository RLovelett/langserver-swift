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

fileprivate let pattern = Data(bytes: [0x0D, 0x0A, 0x0D, 0x0A])

fileprivate func defineHeaderExtent(_ range: Range<Data.Index>) -> Range<Data.Index> {
    return Range<Data.Index>(0..<range.upperBound)
}

fileprivate func seperateHeaderFromBody(_ data: Data) -> (header: Data?, body: Data) {
    guard let headerRange = data.range(of: pattern).map(defineHeaderExtent) else {
        // Default to an empty header set
        // Perhaps this should be an error?
        return (nil, data)
    }
    let bodyRange = Range<Data.Index>(headerRange.upperBound..<data.count)
    return (data.subdata(in: headerRange), data.subdata(in: bodyRange))
}

/// This type represents the 
public struct Request {

    public enum Identifier {
        case string(String)
        case number(Int)
        case null
    }

    public let method: String

    public let id: Identifier

    private let params: JSON

    public init(_ data: Data) throws {
        let (_, body) = seperateHeaderFromBody(data)

        guard let serialized = try? JSONSerialization.jsonObject(with: body, options: []) else {
            throw PredefinedError.parse
        }

        let json = JSON(serialized)

        let dMethod: Decoded<String> = (json <| "method")
        let dId: Decoded<Identifier> = (json <| "id")
        // A Structured value that holds the parameter values to be used during the invocation of
        // the method. This member MAY be omitted.
        let dParams: Decoded<JSON> = (json <| "params") <|> pure(.null)

        switch (dMethod, dId, dParams) {
        case (.success(let m), .success(let i), .success(let j)):
            method = m
            id = i
            params = j
        default:
            throw PredefinedError.invalidRequest
        }
    }

    public func parse<T: Decodable>() throws -> T where T.DecodedType == T {
        switch T.decode(params) {
        case .success(let p):
            return p
        case .failure(_):
            throw PredefinedError.invalidParams
        }
    }
}

extension Request.Identifier : Decodable {

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
        case (.null, .null):
            return true
        default:
            return false
        }
    }

}
