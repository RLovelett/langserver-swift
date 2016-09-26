public protocol ServerError {
    var code: Int { get }
    var message: String { get }
    var data: Any? { get }
}

public enum PredefinedError: Int, Error {
    /// Invalid JSON was received by the server.
    case Parse = -32700

    /// The JSON sent is not a valid Request object.
    case InvalidRequest = -32600

    /// The method does not exist / is not available.
    case MethodNotFound = -32601

    /// Invalid method parameter(s).
    case InvalidParams = -32602

    /// Internal JSON-RPC error.
    case InternalError = -32603
}

extension PredefinedError: ServerError {
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

extension PredefinedError: CustomStringConvertible {
    public var description: String {
        switch self {
        case .Parse: return "Parse error"
        case .InvalidRequest: return "Invalid Request"
        case .MethodNotFound: return "Method not found"
        case .InvalidParams: return "Invalid params"
        case .InternalError: return "Internal error"
        }
    }
}

extension PredefinedError: CustomDebugStringConvertible {
    public var debugDescription: String {
        switch self {
        case .Parse: return "Invalid JSON was received by the server. An error occurred on the server while parsing the JSON text."
        case .InvalidRequest: return "The JSON sent is not a valid Request object."
        case .MethodNotFound: return "The method does not exist / is not available."
        case .InvalidParams: return "Invalid method parameter(s)."
        case .InternalError: return "Internal JSON-RPC error."
        }
    }
}
