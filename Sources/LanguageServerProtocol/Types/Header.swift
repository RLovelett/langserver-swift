//
//  Header.swift
//  langserver-swift
//
//  Created by Ryan Lovelett on 12/8/16.
//
//

import Foundation

struct Header {

    let contentLength: Int?

    init(_ data: Data) {
        self.init(FieldIterator(data))
    }

    private init<I: IteratorProtocol>(_ iterator: I) where I.Element == HeaderField {
        self.init(AnySequence() { iterator })
    }

    private init<S: Sequence>(_ sequence: S) where S.Iterator.Element == HeaderField {
        contentLength = sequence
            .first(where: { $0.name.lowercased() == "content-length" })
            .flatMap({ Int($0.value, radix: 10) })
    }

}
