//
//  SourceKitRequestable.swift
//  langserver-swift
//
//  Created by Ryan Lovelett on 12/11/16.
//
//

import SourceKit

protocol SourceKitRequestable {
    var sourceKitObject: sourcekitd_object_t { get }
}
