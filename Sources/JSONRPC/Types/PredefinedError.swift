//
//  PredefinedError.swift
//  langserver-swift
//
//  Created by Ryan Lovelett on 11/22/16.
//
//

public enum PredefinedError : Int {
    /// Invalid JSON was received by the server.
    case parse = -32700

    /// The JSON sent is not a valid Request object.
    case invalidRequest = -32600

    /// The method does not exist / is not available.
    case methodNotFound = -32601

    /// Invalid method parameter(s).
    case invalidParams = -32602

    /// Internal JSON-RPC error.
    case internalError = -32603
}

extension PredefinedError : ServerError {

    public var code: Int {
        return self.rawValue
    }

    public var message: String {
        return self.description
    }

    public var data: Any? {
        return .none
    }

}

extension PredefinedError : CustomStringConvertible {

    public var description: String {
        switch self {
        case .parse:
            return "Parse error"
        case .invalidRequest:
            return "Invalid Request"
        case .methodNotFound:
            return "Method not found"
        case .invalidParams:
            return "Invalid params"
        case .internalError:
            return "Internal error"
        }
    }

}

extension PredefinedError : CustomDebugStringConvertible {

    public var debugDescription: String {
        switch self {
        case .parse:
            return "Invalid JSON was received by the server. An error occurred on the server while parsing the JSON text."
        case .invalidRequest:
            return "The JSON sent is not a valid Request object."
        case .methodNotFound:
            return "The method does not exist / is not available."
        case .invalidParams:
            return "Invalid method parameter(s)."
        case .internalError:
            return "Internal JSON-RPC error."
        }
    }

}
