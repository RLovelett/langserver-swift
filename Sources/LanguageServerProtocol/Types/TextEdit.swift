//
//  TextEdit.swift
//  langserver-swift
//
//  Created by Ryan Lovelett on 12/2/16.
//
//

import Argo
import Ogra

/// A textual edit applicable to a text document.
///
/// - Note: If n `TextEdit`s are applied to a text document all text edits describe changes to the
/// initial document version. Execution wise text edits should applied from the bottom to the top of
/// the text document. Overlapping text edits are not supported.
struct TextEdit {

    /// The range of the text document to be manipulated. To insert text into a document create a
    /// range where `start === end`.
    let range: TextDocumentRange

    /// The string to be inserted. For delete operations use an empty string.
    let newText: String

}

extension TextEdit : Ogra.Encodable {

    func encode() -> JSON {
        return JSON.null
    }

}
