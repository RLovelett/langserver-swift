//
//  URL.swift
//  langserver-swift
//
//  Created by Ryan Lovelett on 3/19/17.
//
//

import Foundation
import SourceKit

extension URL : SourceKitRequestable {
    var sourceKitObject: sourcekitd_object_t {
        return sourcekitd_request_string_create(self.path)
    }
}
