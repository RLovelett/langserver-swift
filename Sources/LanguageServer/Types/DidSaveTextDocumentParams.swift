struct DidSaveTextDocumentParams {

    /// The document that was saved.
    let textDocument: TextDocumentIdentifier

    init?(parse json: Any?) {
        guard let dict = json as? [String : Any] else {
            return nil
        }

        guard let document = TextDocumentIdentifier(parse: dict["textDocument"]) else {
            return nil
        }

        self.textDocument = document
    }

}
