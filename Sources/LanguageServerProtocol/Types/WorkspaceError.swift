//
//  WorkspaceError.swift
//  langserver-swift
//
//  Created by Ryan Lovelett on 11/25/16.
//
//

import Foundation
import JSONRPC

enum WorkspaceError : ServerError {

    case notFound(URL)

    case positionNotFound

    case sourceKit

}

extension WorkspaceError {

    var code: Int {
        switch self {
        case .notFound(_):
            return -32099
        case .positionNotFound:
            return -32098
        case .sourceKit:
            return -32097
        }
    }

    var message: String {
        switch self {
        case .notFound(let url):
            return "Could not find \(url.path) in the workspace."
        case .positionNotFound:
            return "Could not find the text in the source file."
        case .sourceKit:
            return "There was an error communicating with SourceKit."
        }
    }

    var data: Any? { return .none }

}
