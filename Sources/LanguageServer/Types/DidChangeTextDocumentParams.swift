struct DidChangeTextDocumentParams {

    /// The document that did change. The version number points to the version after all provided
    /// content changes have been applied.
    let textDocument: VersionedTextDocumentIdentifier

    /// The actual content changes.
    let contentChanges: [TextDocumentContentChangeEvent]

    init?(parse json: Any?) {
        guard let dict = json as? [String : Any] else {
            return nil
        }

        guard let document = VersionedTextDocumentIdentifier(parse: dict["textDocument"]) else {
            return nil
        }

        guard let changeSet = dict["contentChanges"] as? [[String : Any]] else {
            return nil
        }

        self.textDocument = document
        self.contentChanges = changeSet.flatMap(TextDocumentContentChangeEvent.init(parse:))
    }

}
