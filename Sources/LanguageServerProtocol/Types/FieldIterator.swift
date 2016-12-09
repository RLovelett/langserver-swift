//
//  FieldIterator.swift
//  langserver-swift
//
//  Created by Ryan Lovelett on 12/8/16.
//
//

import Foundation

fileprivate let terminator = Data(bytes: [0x0D, 0x0A]) // "\r\n"

struct FieldIterator {

    let header: Data

    var index: Data.Index

    init(_ data: Data) {
        header = data
        index = data.startIndex
    }

    var range: Range<Data.Index> {
        return index..<header.endIndex
    }
}

extension FieldIterator : IteratorProtocol {

    mutating func next() -> HeaderField? {
        let foo = header.range(of: terminator, options: [], in: range) ?? (header.endIndex..<header.endIndex)
        let bar = Range<Data.Index>(index..<foo.lowerBound)
        let fieldData = header.subdata(in: bar)
        index = foo.upperBound
        return HeaderField(fieldData)
    }

}
