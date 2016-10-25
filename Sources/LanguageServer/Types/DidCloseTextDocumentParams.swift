struct DidCloseTextDocumentParams {

    /// The document that was closed.
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
