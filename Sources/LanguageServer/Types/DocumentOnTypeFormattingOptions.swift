/**
 * Format document on type options
 */
struct DocumentOnTypeFormattingOptions {
    /**
     * A character on which formatting should be triggered, like `}`.
     */
    let firstTriggerCharacter: String;
    /**
     * More trigger characters.
     */
    let moreTriggerCharacter: [String]?
}
