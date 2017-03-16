//
//  Header.swift
//  langserver-swift
//
//  Created by Ryan Lovelett on 12/8/16.
//
//

import Foundation

private let terminator = Data(bytes: [0x0D, 0x0A]) // "\r\n"
private let separatorBytes = Data(bytes: [0x3A, 0x20]) // ": "

/// The `Header` provides an iterator interface to the header part of the base protocol of language
/// server protocol.
///
/// Communications between the server and the client in the language server protocol consist of a header (comparable to
/// HTTP) and a content part (which conforms to [JSON-RPC](http://www.jsonrpc.org)).
struct Header : IteratorProtocol {

    /// Each `Header.Field` can be viewed as a single, logical line of ASCII characters, comprising a field-name and a
    /// field-body.
    ///
    /// - Warning: While `Header`, `Fields` and `Field` strive to be spec compliant they may not actually be. Any
    /// any discrepancies should be reported.
    ///
    /// - SeeAlso: [RFC 822 Section 3.1](http://www.ietf.org/rfc/rfc0822.txt)
    /// - SeeAlso: [RFC 7230, Section 3.2 - Header Fields](https://tools.ietf.org/html/rfc7230#section-3.2)
    struct Field {

        /// The name of a field in a header.
        let name: String

        /// The body, or value, of a field in a header.
        let body: String

        /// Initialize a `Field` by parsing the byte buffer. If the buffer does not conform to the specification then
        /// the `Field` will fail to initialize.
        ///
        /// Where possible the data should conform to RFC 7230, Section 3.2 - Header Fields.
        ///
        /// - Parameter data: A byte buffer that contains a RFC 7230 header field.
        /// - SeeAlso: [RFC 7230, Section 3.2 - Header Fields](https://tools.ietf.org/html/rfc7230#section-3.2)
        init?(_ data: Data) {
            guard let seperator = data.range(of: separatorBytes) else { return nil }
            guard let n = String(data: data.subdata(in: data.startIndex..<seperator.lowerBound), encoding: .utf8) else { return nil }
            guard let b = String(data: data.subdata(in: seperator.upperBound..<data.endIndex), encoding: .utf8) else { return nil }
            name = n
            body = b
        }
    }

    /// A byte buffer that contains the complete header information of a message.
    private let header: Data

    /// The index of the first byte of the next `Header.Field`.
    private var index: Data.Index

    /// Initialize a `Header` iterator with the provided byte buffer.
    ///
    /// - Parameter data: A byte buffer that contains the header part of the base protocol.
    init(_ data: Data) {
        header = data
        index = data.startIndex
    }

    /// The range of the byte buffer that should be checked for the next `Header.Field`.
    private var range: Range<Data.Index> {
        return index..<header.endIndex
    }

    /// Attempt to parse a `Header.Field` from the `Header`'s byte buffer.
    ///
    /// - Returns: The next valid `Header.Field` or nil if all valid `Header.Fields` have been parsed.
    mutating func next() -> Header.Field? {
        let foo = header.range(of: terminator, options: [], in: range) ?? (header.endIndex..<header.endIndex)
        let bar = Range<Data.Index>(index..<foo.lowerBound)
        let fieldData = header.subdata(in: bar)
        index = foo.upperBound
        return Header.Field(fieldData)
    }

    /// A conveinence property to find the `Header.Field` with the name `Content-Length`. If it exists, and convert it
    /// then convert the field's body to an `Int`.
    ///
    /// - Note: This field may not exist in the `Header`. In that case the `Optional` is `none`.
    var contentLength: Int? {
        return AnySequence({ self })
            .first(where: { $0.name.lowercased() == "content-length" })
            .flatMap({ Int($0.body, radix: 10) })
    }

}
