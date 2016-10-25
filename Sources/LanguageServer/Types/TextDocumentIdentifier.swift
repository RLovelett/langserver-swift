/// Text documents are identified using a URI. On the protocol level, URIs are passed as strings.
/// The corresponding JSON structure looks like this:
struct TextDocumentIdentifier {

    /// The text document's URI.
    let uri: String

    init?(parse json: Any?) {
        guard let dict = json as? [String : Any] else {
            return nil
        }

        guard let uri = dict["uri"] as? String else {
            return nil
        }

        self.uri = uri
    }

}
