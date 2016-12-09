//
//  RequestIterator.swift
//  langserver-swift
//
//  Created by Ryan Lovelett on 12/8/16.
//
//

import Foundation

fileprivate let terminatorPattern = Data(bytes: [0x0D, 0x0A, 0x0D, 0x0A]) // "\r\n\r\n"

public struct RequestIterator {

  fileprivate var iterator: MultibyteDataIterator

  public init(_ data: Data) {
    iterator = MultibyteDataIterator(split: data, onSeparator: terminatorPattern) {
      Header($0).contentLength
    }
  }

}

extension RequestIterator : IteratorProtocol {

  mutating public func next() -> Data? {
    return iterator.next()
  }

}
