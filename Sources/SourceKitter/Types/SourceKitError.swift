//
//  SourceKitError.swift
//  langserver-swift
//
//  Created by Ryan Lovelett on 12/11/16.
//
//

import SourceKit

/// A enum representation of `SOURCEKITD_ERROR_*`
enum SourceKitError : Error, CustomStringConvertible {
    case connectionInterrupted(String?)
    case invalid(String?)
    case failed(String?)
    case cancelled(String?)
    case unknown(String?)

    init(_ response: sourcekitd_response_t) {
        let cStr = sourcekitd_response_error_get_description(response)!
        // TODO: Do I need to release the cStr?
        let description = String(validatingUTF8: cStr)
        switch sourcekitd_response_error_get_kind(response) {
        case SOURCEKITD_ERROR_CONNECTION_INTERRUPTED: self = .connectionInterrupted(description)
        case SOURCEKITD_ERROR_REQUEST_INVALID: self = .invalid(description)
        case SOURCEKITD_ERROR_REQUEST_FAILED: self = .failed(description)
        case SOURCEKITD_ERROR_REQUEST_CANCELLED: self = .cancelled(description)
        default: self = .unknown(description)
        }
    }

    var description: String {
        return "Do this right!"
    }
}
