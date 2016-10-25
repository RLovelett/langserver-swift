/// An event describing a change to a text document. If range and rangeLength are omitted the new
/// text is considered to be the full content of the document.
struct TextDocumentContentChangeEvent {

    /// The range of the document that changed.
//    range?: Range

    /// The length of the range that got replaced.
    let rangeLength: UInt?

    /// The new text of the document.
    let text: String

    init?(parse json: Any?) {
        guard let dict = json as? [String : Any] else {
            return nil
        }

        guard let text = dict["text"] as? String else {
            return nil
        }

        self.text = text
        self.rangeLength = nil
    }

}
