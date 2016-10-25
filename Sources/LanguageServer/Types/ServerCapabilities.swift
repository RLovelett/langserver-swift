/// The capabilities the language server provides.
struct ServerCapabilities {
    /// Defines how text documents are synced.
    let textDocumentSync: TextDocumentSyncKind?

    /// The server provides hover support.
    let hoverProvider: Bool?

    /// The server provides completion support.
    let completionProvider: CompletionOptions?

    /// The server provides signature help support.
    let signatureHelpProvider: SignatureHelpOptions?

    /// The server provides goto definition support.
    let definitiionProvider: Bool?

    /// The server provides find references support.
    let referencesProvider: Bool?

    /// The server provides document highlight support.
    let documentHighlighProvider: Bool?

    /// The server provides document symbol support.
    let documentSymbolProvider: Bool?

    /// The server provides workspace symbol support.
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

    /// Convert the instance into a type that can be serialized as JSON.
    var toJSON: [String : Any] {
        var obj: [String : Any] = [:]

        if let textDocumentSync = self.textDocumentSync {
            obj["textDocumentSync"] = textDocumentSync.rawValue
        }

        if let hoverProvider = self.hoverProvider {
            obj["hoverProvider"] = hoverProvider
        }

        if let workspaceSymbolProvider = self.workspaceSymbolProvider {
            obj["workspaceSymbolProvider"] = workspaceSymbolProvider
        }

        return obj
    }
}
