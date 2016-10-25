/// An item to transfer a text document from the client to the server.
struct TextDocumentItem {

    /// The text document's URI.
    let uri: String

    /// The text document's language identifier.
    let languageId: String

    /// The version number of this document (it will strictly increase after each change, including
    /// undo/redo).
    let version: UInt

    /// The content of the opened text document.
    let text: String


    init?(parse json: Any?) {
        guard let dict = json as? [String : Any] else {
            return nil
        }

        guard let uri = dict["uri"] as? String else {
            return nil
        }

        guard let languageId = dict["languageId"] as? String else {
            return nil
        }

        guard let version = dict["version"] as? UInt else {
            return nil
        }

        guard let text = dict["text"] as? String else {
            return nil
        }

        self.uri = uri
        self.languageId = languageId
        self.version = version
        self.text = text
    }

}
