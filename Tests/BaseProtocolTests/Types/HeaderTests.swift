//
//  HeaderTests.swift
//  langserver-swift
//
//  Created by Ryan Lovelett on 12/8/16.
//
//

@testable import BaseProtocol
import XCTest

class HeaderTests: XCTestCase {

    func testHeaderWithNumericContentLength() {
        let d = loadFixture("shutdown.txt", in: "JSON-RPC/Requests")!
        let header = Header(d)
        XCTAssertEqual(header.contentLength, 58)
    }

    func testHeaderWithoutContentLength() {
        let d = loadFixture("non-numeric-content-length.txt", in: "JSON-RPC/Requests")!
        let header = Header(d)
        XCTAssertNil(header.contentLength)
    }

    func testHeaderWithMultipleFields() {
        let d = loadFixture("multiple-field-header.txt", in: "JSON-RPC/Requests")!
        var it = Header(d)

        // Content-Length: 271
        let contentLength = it.next()
        XCTAssertEqual(contentLength?.name, "Content-Length")
        XCTAssertEqual(contentLength?.body, "271")

        // Content-Type: application/vscode-jsonrpc; charset=utf8
        let contentType = it.next()
        XCTAssertEqual(contentType?.name, "Content-Type")
        XCTAssertEqual(contentType?.body, "application/vscode-jsonrpc; charset=utf8")

        // Date: Thu, 08 Dec 2016 18:41:04 GMT
        let date = it.next()
        XCTAssertEqual(date?.name, "Date")
        XCTAssertEqual(date?.body, "Thu, 08 Dec 2016 18:41:04 GMT")

        // 🏁
        XCTAssertNil(it.next())
    }

}
