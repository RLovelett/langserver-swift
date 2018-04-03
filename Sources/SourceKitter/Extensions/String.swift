//
//  String.swift
//  langserver-swift
//
//  Created by Ryan Lovelett on 12/11/16.
//
//

import Foundation
import SourceKit

extension String : SourceKitRequestable {
    var isFile: Bool {
        return FileManager.default.fileExists(atPath: self)
    }

    var sourceKitObject: sourcekitd_object_t? {
        return sourcekitd_request_string_create(self)
    }
}
