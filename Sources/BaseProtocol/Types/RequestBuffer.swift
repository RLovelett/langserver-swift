//
//  RequestBuffer.swift
//  langserver-swift
//
//  Created by Ryan Lovelett on 12/8/16.
//
//

import Foundation
import os.log

@available(macOS 10.12, *)
private let log = OSLog(subsystem: "me.lovelett.langserver-swift", category: "RequestBuffer")
private let terminatorPattern = Data(bytes: [0x0D, 0x0A, 0x0D, 0x0A]) // "\r\n\r\n"

public class RequestBuffer {

    fileprivate var buffer: Data

    public init(_ data: Data? = nil) {
        buffer = data ?? Data()
    }

    public func append(_ data: Data) {
        if #available(macOS 10.12, *) {
            os_log("Adding %{iec-bytes}d to the request buffer which has %{iec-bytes}d", log: log, type: .default, data.count, buffer.count)
        }
        buffer.append(data)
        if #available(macOS 10.12, *), let new = String(bytes: data, encoding: .utf8), let buffer = String(bytes: buffer, encoding: .utf8) {
            os_log("Added: %{public}@", log: log, type: .default, new)
            os_log("Buffer: %{public}@", log: log, type: .default, buffer)
        }
    }

}

extension RequestBuffer : IteratorProtocol {

    public func next() -> Data? {
        guard !buffer.isEmpty else { return nil }
        let separatorRange = buffer.range(of: terminatorPattern) ?? (buffer.endIndex..<buffer.endIndex)
        let extractedData = buffer.subdata(in: buffer.startIndex..<separatorRange.lowerBound)
        let distance = Header(extractedData).contentLength ?? 0
        guard let index = buffer.index(separatorRange.upperBound, offsetBy: distance, limitedBy: buffer.endIndex) else {
            return nil
        }
        defer {
            buffer.removeSubrange(Range<Data.Index>(buffer.startIndex..<index))
            if #available(macOS 10.12, *) {
                let bytes = buffer.startIndex.distance(to: index)
                os_log("Removing %{iec-bytes}d from the request buffer which has %{iec-bytes}d", log: log, type: .default, bytes, buffer.count)
            }

        }
        return buffer.subdata(in: Range<Data.Index>(separatorRange.upperBound..<index))
    }

}

extension RequestBuffer : Sequence {

    public func makeIterator() -> RequestBuffer {
        return self
    }

}
