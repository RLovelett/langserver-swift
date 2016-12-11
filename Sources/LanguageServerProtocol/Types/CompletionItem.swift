//
//  CompletionItem.swift
//  langserver-swift
//
//  Created by Ryan Lovelett on 12/2/16.
//
//

import Argo
import Curry
import Foundation
import JSONRPC
import Ogra
import Runes

///
public struct CompletionItem {

    /// The label of this completion item. By default also the text that is inserted when selecting
    /// this completion.
    var label: String

    /// The kind of this completion item. Based of the kind an icon is chosen by the editor.
    var kind: CompletionItemKind?

    /// A human-readable string with additional information about this item, like type or symbol
    /// information.
    var detail: String?

    /// A human-readable string that represents a doc-comment.
    var documentation: String?

    /// A string that shoud be used when comparing this item with other items. When `falsy` the
    /// label is used.
    var sortText: String?

    /// A string that should be used when filtering a set of completion items. When `falsy` the
    /// label is used.
    var filterText: String?

    /// A string that should be inserted a document when selecting this completion. When `falsy` the
    /// label is used.
    var insertText: String?

    /// An edit which is applied to a document when selecting this completion. When an edit is
    /// provided the value of insertText is ignored.
    var textEdit: TextEdit?

    /// An optional array of additional text edits that are applied when selecting this completion.
    /// Edits must not overlap with the main edit nor with themselves.
    var additionalTextEdits: [TextEdit]?

    /// An optional command that is executed *after* inserting this completion.
    ///
    /// - Note: That additional modifications to the current document should be described with the
    /// `additionalTextEdits`-property.
    var command: Command?

    /// An data entry field that is preserved on a completion item between a completion and a
    /// completion resolve request.
    var data: Any?

}

extension CompletionItem : Encodable {

    public func encode() -> JSON {
        var obj: [String : JSON] = [
            "label" : JSON.string(label)
        ]

        if let kind = self.kind {
            obj["kind"] = JSON.number(NSNumber(value: kind.rawValue))
        }

        if let detail = self.detail {
            obj["detail"] = JSON.string(detail)
        }

        if let documentation = self.documentation {
            obj["documentation"] = JSON.string(documentation)
        }

        if let sortText = self.sortText {
            obj["sortText"] = JSON.string(sortText)
        }

        if let filterText = self.filterText {
            obj["filterText"] = JSON.string(filterText)
        }

        if let insertText = self.insertText {
            obj["insertText"] = JSON.string(insertText)
        }

        if let textEdit = self.textEdit {
            obj["textEdit"] = textEdit.encode()
        }
//
//        if let additionalTextEdits = self.additionalTextEdits {
//            obj["additionalTextEdits"] = additionalTextEdits.flatMap({ $0.message })
//        }
//
//        if let command = self.command {
//            obj["command"] = command.encode()
//        }
//
//        if let data = self.data {
//            obj["data"] = data
//        }

        return JSON.object(obj)
    }

}

extension CompletionItem : Decodable {

    fileprivate init(description: String, k: CompletionItemKind?, sourcetext: String, type: String?, brief: String?, context: String, bytesToErase: Int, associatedUSRs: String?, name: String, module: String?, notRecommended: Bool?) {
        label = description
        detail = description
        kind = k
        documentation = brief
        sortText = nil
        filterText = nil
        insertText = sourcetext
        textEdit = nil
        additionalTextEdits = nil
        command = nil
        data = nil

        let base = type?.prepend(module, separator: ".")
        switch k! {
//        case .Text:
//        case .Method:
        case .Function:
            detail = base?.prepend(description, separator: " -> ")
        case .Constructor:
            detail = description.prepend(base, separator: " ")
//        case .Field:
//        case .Variable:
//        case .Class:
//        case .Interface:
//        case .Module:
//        case .Property:
//        case .Unit:
//        case .Value:
//        case .Enum:
//        case .Keyword:
//        case .Snippet:
//        case .Color:
//        case .File:
//        case .Reference:
        default:
            detail = description
        }
    }

    /// completion-result ::=
    /// {
    ///   <key.description>:    (string)    // Text to be displayed in code-completion window.
    ///   <key.kind>:           (UID)       // UID for the declaration kind (function, class, etc.).
    ///   <key.sourcetext>:     (string)    // Text to be inserted in source.
    ///   <key.typename>:       (string)    // Text describing the type of the result.
    ///   <key.doc.brief>:      (string)    // Brief documentation comment attached to the entity.
    ///   <key.context>:        (UID)       // Semantic context of the code completion result.
    ///   <key.num_bytes_to_erase>: (int64) // Number of bytes to the left of the cursor that should be erased before inserting this completion result.
    /// }
    ///
    /// ```
    /// $ cat Fixtures/JSON/complete.json | jq '.[] | map(keys) | flatten | unique'
    /// [
    ///   "key.associated_usrs",
    ///   "key.context",
    ///   "key.description",
    ///   "key.doc.brief",
    ///   "key.kind",
    ///   "key.modulename",
    ///   "key.name",
    ///   "key.not_recommended",
    ///   "key.num_bytes_to_erase",
    ///   "key.sourcetext",
    ///   "key.typename"
    /// ]
    /// ```
    ///
    ///
    /// - Remark: Need to document:
    /// "key.name" : "#colorLiteral(red:green:blue:alpha:)"
    public static func decode(_ json: JSON) -> Decoded<CompletionItem> {
        let description: Decoded<String> = json <| "key.description"
        let kind: Decoded<CompletionItemKind?> = json <|? "key.kind"
        let sourcetext: Decoded<String> = (json <| "key.sourcetext").flatMap(convert)
        let type: Decoded<String?> = json <|? "key.typename"
        let brief: Decoded<String?> = json <|? "key.doc.brief"
        let context: Decoded<String> = json <| "key.context"
        let bytesToErase: Decoded<Int> = json <| "key.num_bytes_to_erase"

        let associatedUSRs: Decoded<String?> = json <|? "key.associated_usrs"
        let name: Decoded<String> = json <| "key.name"
        let module: Decoded<String?> = json <|? "key.modulename"
        let notRecommended: Decoded<Bool?> = json <|? "key.not_recommended"

        let x = curry(CompletionItem.init)
            <^> description
            <*> kind
            <*> sourcetext
            <*> type
            <*> brief
            <*> context
            <*> bytesToErase
            <*> associatedUSRs
            <*> name
            <*> module
            <*> notRecommended

        return x
    }

}
