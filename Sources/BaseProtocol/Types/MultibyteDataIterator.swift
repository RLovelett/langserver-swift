//
//  MultibyteDataIterator.swift
//  langserver-swift
//
//  Created by Ryan Lovelett on 12/8/16.
//
//

import Foundation

struct MultibyteDataIterator {

    let separator: Data

    var data: Data

    fileprivate let calculateNewIndex: (Data) -> Data.Index?

    init(split: inout Data, onSeparator: Data, calculateIndex: @escaping (Data) -> Data.Index?) {
        separator = onSeparator
        data = split
        calculateNewIndex = calculateIndex
    }

    mutating func append(_ data: Data) {
        self.data.append(data)
    }

}

extension MultibyteDataIterator : IteratorProtocol {

    mutating func next() -> Data? {
        guard !data.isEmpty else { return nil }
        let separatorRange = data.range(of: separator) ?? (data.endIndex..<data.endIndex)
        let extractedData = data.subdata(in: data.startIndex..<separatorRange.lowerBound)
        let distance = calculateNewIndex(extractedData) ?? 0
        guard let index = data.index(separatorRange.upperBound, offsetBy: distance, limitedBy: data.endIndex) else {
            return nil
        }
        defer { data.removeSubrange(Range<Data.Index>(data.startIndex..<index)) }
        return data.subdata(in: Range<Data.Index>(separatorRange.upperBound..<index))
    }

}
