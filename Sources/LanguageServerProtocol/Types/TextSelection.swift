//
//  TextSelection.swift
//  langserver-swift
//
//  Created by Ryan Lovelett on 11/23/16.
//
//

import Foundation

struct TextSelection : TextDocumentRange {

    /// The range's start position.
    let start: Position

    /// The range's start position.
    let end: Position

}
