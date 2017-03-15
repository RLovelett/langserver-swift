//
//  RequestIterator.swift
//  langserver-swift
//
//  Created by Ryan Lovelett on 12/8/16.
//
//

import Foundation
import os.log

@available(macOS 10.12, *)
private let log = OSLog(subsystem: "me.lovelett.langserver-swift", category: "RequestIterator")
fileprivate let terminatorPattern = Data(bytes: [0x0D, 0x0A, 0x0D, 0x0A]) // "\r\n\r\n"

public struct RequestIterator {

    fileprivate var iterator: MultibyteDataIterator

    public init(_ data: Data) {
        iterator = MultibyteDataIterator(split: data, onSeparator: terminatorPattern) {
            Header($0).contentLength
        }
    }

    mutating public func append(_ data: Data) {
        if #available(macOS 10.12, *) {
            os_log("Adding %{iec-bytes}d to the request buffer which has %{iec-bytes}d", log: log, type: .default, data.count, iterator.data.count)
        }
        iterator.append(data)
        if #available(macOS 10.12, *), let new = String(bytes: data, encoding: .utf8), let buffer = String(bytes: iterator.data, encoding: .utf8) {
            os_log("Added: %{public}@", log: log, type: .default, new)
            os_log("Buffer: %{public}@", log: log, type: .default, buffer)
        }
    }

}

extension RequestIterator : IteratorProtocol {

    mutating public func next() -> Data? {
        return iterator.next()
    }

}
