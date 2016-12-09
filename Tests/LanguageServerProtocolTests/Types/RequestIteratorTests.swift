//
//  RequestIteratorTests.swift
//  langserver-swift
//
//  Created by Ryan Lovelett on 12/8/16.
//
//

@testable import LanguageServerProtocol
import XCTest

class RequestIteratorTests: XCTestCase {

    func testIteratingMultipleRequestsAndHeaders() {
        let d = loadFixture("multiple-requests-and-headers.txt", in: "JSON-RPC/Requests")!
        var it = RequestIterator(d)

        let first = it.next()
        XCTAssertEqual(first?.count, 271)

        let second = it.next()
        XCTAssertEqual(second?.count, 222)

        // 🏁
        XCTAssertNil(it.next())
    }

}
