//
//  FieldIteratorTests.swift
//  langserver-swift
//
//  Created by Ryan Lovelett on 12/8/16.
//
//

@testable import LanguageServerProtocol
import XCTest

class FieldIteratorTests: XCTestCase {

    func testHeaderWithMultipleFields() {
        let d = loadFixture("multiple-field-header.txt", in: "JSON-RPC/Requests")!
        var it = FieldIterator(d)

        // Content-Length: 271
        let contentLength = it.next()
        XCTAssertEqual(contentLength?.name, "Content-Length")
        XCTAssertEqual(contentLength?.value, "271")

        // Content-Type: application/vscode-jsonrpc; charset=utf8
        let contentType = it.next()
        XCTAssertEqual(contentType?.name, "Content-Type")
        XCTAssertEqual(contentType?.value, "application/vscode-jsonrpc; charset=utf8")

        // Date: Thu, 08 Dec 2016 18:41:04 GMT
        let date = it.next()
        XCTAssertEqual(date?.name, "Date")
        XCTAssertEqual(date?.value, "Thu, 08 Dec 2016 18:41:04 GMT")

        // 🏁
        XCTAssertNil(it.next())
    }

}
