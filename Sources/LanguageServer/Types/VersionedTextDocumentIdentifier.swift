struct VersionedTextDocumentIdentifier {

    /// The text document's URI.
    let uri: String

    /// The version number of this document.
    let version: UInt

    init?(parse json: Any?) {
        guard let dict = json as? [String : Any] else {
            return nil
        }

        guard let uri = dict["uri"] as? String else {
            return nil
        }

        guard let version = dict["version"] as? UInt else {
            return nil
        }

        self.uri = uri
        self.version = version
    }

}
