//
//  RequestType.swift
//  langserver-swift
//
//  Created by Ryan Lovelett on 3/19/17.
//
//

import SourceKit

enum RequestType : SourceKitRequestable {
    case cursorInfo
    case codeComplete

    var sourceKitObject: sourcekitd_object_t? {
        let str: String
        switch self {
        case .cursorInfo:
            str = "source.request.cursorinfo"
        case .codeComplete:
            str = "source.request.codecomplete"
        }
        return sourcekitd_uid_get_from_cstr(str).flatMap { sourcekitd_request_uid_create($0) }
    }
}
