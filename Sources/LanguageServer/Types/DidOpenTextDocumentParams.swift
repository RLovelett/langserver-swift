/// <#Description#>
struct DidOpenTextDocumentParams {

    /// The document that was opened.
    let textDocument: TextDocumentItem

    init?(parse json: Any?) {
        guard let dict = json as? [String : Any] else {
            return nil
        }

        guard let documentJSON = dict["textDocument"] as? [String : Any] else {
            return nil
        }

        guard let document = TextDocumentItem(parse: documentJSON) else {
            return nil
        }

        textDocument = document
    }

}
