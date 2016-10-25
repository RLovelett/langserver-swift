/// The initialize request is sent as the first request from the client to the server.
struct InitializeParams {

    /// The process Id of the parent process that started the server. Is null if the process has not
    /// been started by another process.
    /// If the parent process is not alive then the server should exit (see exit notification) its
    /// process.
    let processId: Int?

    /// The rootPath of the workspace. Is null if no folder is open.
    let rootPath: String?

    /// User provided initialization options.
    let initializationOptions: Any?

    init?(parse json: Any?) {
        guard let dict = json as? [String : Any] else {
            return nil
        }

        processId = dict["processId"] as? Int
        rootPath = dict["rootPath"] as? String
        initializationOptions = .none
    }
}
