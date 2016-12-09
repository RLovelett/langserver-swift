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

    let data: Data

    var index: Data.Index

    fileprivate let calculateNewIndex: (Data) -> Data.Index?

    init(split: Data, onSeparator: Data, calculateIndex: @escaping (Data) -> Data.Index?) {
        separator = onSeparator
        data = split
        index = split.startIndex
        calculateNewIndex = calculateIndex
    }

}

extension MultibyteDataIterator : IteratorProtocol {

    mutating func next() -> Data? {
        guard index < data.endIndex else { return nil }
        let separatorRange = data.range(of: separator, options: [], in: index..<data.endIndex) ?? (data.endIndex..<data.endIndex)
        let extractedData = data.subdata(in: index..<separatorRange.lowerBound)
        let distance = calculateNewIndex(extractedData) ?? 0
        index = data.index(separatorRange.upperBound, offsetBy: distance)
        return data.subdata(in: Range<Data.Index>(separatorRange.upperBound..<index))
    }

}
