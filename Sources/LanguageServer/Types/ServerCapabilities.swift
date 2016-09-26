struct ServerCapabilities {
    let textDocumentSync: TextDocumentSyncKind?
    let hoverProvider: Bool?
    let completionProvider: CompletionOptions?
    let signatureHelpProvider: SignatureHelpOptions?
    let definitiionProvider: Bool?
    let referencesProvider: Bool?
    let documentHighlighProvider: Bool?
    let documentSymbolProvider: Bool?
    let workspaceSymbolProvider: Bool?
    /// The server provides code actions.
    let codeActionProvider: Bool?
    /// The server provides code lens.
    let codeLensProvider: CodeLensOptions?
    /// The server provides document formatting.
    let documentFormattingProvider: Bool?
    /// The server provides document range formatting.
    let documentRangeFormattingProvider: Bool?
    /// The server provides document formatting on typing.
    let documentOnTypeFormattingProvider: DocumentOnTypeFormattingOptions?
    /// The server provides rename support.
    let renameProvider: Bool?

    var toJSON: [String : Any] {
        var obj: [String : Any] = [:]

        if let textDocumentSync = self.textDocumentSync {
            obj["textDocumentSync"] = textDocumentSync.rawValue
        }

        return obj
    }
}
