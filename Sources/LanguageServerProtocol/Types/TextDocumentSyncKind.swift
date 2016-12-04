//
//  TextDocumentSyncKind.swift
//  langserver-swift
//
//  Created by Ryan Lovelett on 11/23/16.
//
//

/// Defines how the host (editor) should sync document changes to the langauge server.
public enum TextDocumentSyncKind : Int {

    /// Documents should not be synced at all.
    case None = 0

    /// Documents are synced by always sending the full content of the document.
    case Full = 1

    /// Documents are synced by sending the full content on open. After that only incremental
    /// updates to the document are sent.
    case Incremental = 2

}
