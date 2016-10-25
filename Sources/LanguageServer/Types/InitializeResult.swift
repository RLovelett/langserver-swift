/// The response to the 'initialize' request.
struct InitializeResult {

    /// The capabilities the language server provides.
    let capabilities: ServerCapabilities

    init(_ sc: ServerCapabilities) {
        capabilities = sc
    }

    /// Convert the instance into a type that can be serialized as JSON.
    var toJSON: [String : Any] {
        return [
            "capabilities": capabilities.toJSON
        ]
    }

}
