//
//  Array.swift
//  langserver-swift
//
//  Created by Ryan Lovelett on 3/18/17.
//
//

import SourceKit

extension Array where Element: SourceKitRequestable {
    var sourceKit: sourcekitd_object_t? {
        var request = self.map { $0.sourceKitObject }
        return sourcekitd_request_array_create(&request, request.count)
    }
}
