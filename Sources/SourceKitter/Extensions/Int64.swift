//
//  Int64.swift
//  langserver-swift
//
//  Created by Ryan Lovelett on 3/19/17.
//
//

import SourceKit

extension Int64 : SourceKitRequestable {
    var sourceKitObject: sourcekitd_object_t? {
        return sourcekitd_request_int64_create(self)
    }
}
