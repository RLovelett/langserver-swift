//
//  HeaderField.swift
//  langserver-swift
//
//  Created by Ryan Lovelett on 12/8/16.
//
//

import Foundation

fileprivate let separatorBytes = Data(bytes: [0x3A, 0x20]) // ": "

struct HeaderField {

    let name: String

    let value: String

    init?(_ data: Data) {
        guard let seperator = data.range(of: separatorBytes) else { return nil }
        guard let n = String(data: data.subdata(in: data.startIndex..<seperator.lowerBound), encoding: .utf8) else { return nil }
        guard let v = String(data: data.subdata(in: seperator.upperBound..<data.endIndex), encoding: .utf8) else { return nil }
        name = n
        value = v
    }

}
