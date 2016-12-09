//
//  HeaderTests.swift
//  langserver-swift
//
//  Created by Ryan Lovelett on 12/8/16.
//
//

@testable import LanguageServerProtocol
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

}
