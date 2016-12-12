//
//  Array.swift
//  langserver-swift
//
//  Created by Ryan Lovelett on 3/18/17.
//
//

import SourceKit

extension Array where Element == String {
    var sourceKit: sourcekitd_object_t {
        var requestStrings = self.map({ sourcekitd_request_string_create($0) })
        return sourcekitd_request_array_create(&requestStrings, self.count)
    }
}
