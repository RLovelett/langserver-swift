/**
 * Completion options.
 */
struct CompletionOptions {
    /**
     * The server provides support to resolve additional information for a completion item.
     */
    let resolveProvider: Bool?

    /**
     * The characters that trigger completion automatically.
     */
    let triggerCharacters: [String]?
}
