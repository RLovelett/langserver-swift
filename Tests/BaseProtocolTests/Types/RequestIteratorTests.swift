//
//  RequestIteratorTests.swift
//  langserver-swift
//
//  Created by Ryan Lovelett on 12/8/16.
//
//

@testable import BaseProtocol
import XCTest

class RequestIteratorTests: XCTestCase {

    func testIteratingMultipleRequestsAndHeaders() {
        guard let d = loadFixture("multiple-requests-and-headers.txt", in: "JSON-RPC/Requests") else {
            XCTFail("loadFixture failed")
            return
        }

        let c = Array(AnySequence { RequestBuffer(d) })

        XCTAssertEqual(c.count, 4)
        XCTAssertEqual(c.map({ $0.count }), [270, 62, 271, 222])
    }

    func testIteratingFullAndPartialRequestsWithoutCrash() {
        guard let d = loadFixture("partial-request.txt", in: "JSON-RPC/Requests") else {
            XCTFail("loadFixture failed")
            return
        }

        let it = RequestBuffer(d)

        let first = it.next()
        XCTAssertEqual(first?.count, 282)

        XCTAssertNil(it.next())
        XCTAssertNil(it.next())
        XCTAssertNil(it.next())
        XCTAssertNil(it.next())
    }

    func testIteratingByAppendingBuffers() {
        guard let d1 = loadFixture("partial-request-1.txt", in: "JSON-RPC/Requests") else {
            XCTFail("loadFixture failed")
            return
        }

        guard let d2 = loadFixture("partial-request-2.txt", in: "JSON-RPC/Requests") else {
            XCTFail("loadFixture failed")
            return
        }

        guard let d3 = loadFixture("partial-request-3.txt", in: "JSON-RPC/Requests") else {
            XCTFail("loadFixture failed")
            return
        }

        let it = RequestBuffer(Data())
        // Since no data was sent to start it should have nothing in it
        XCTAssertNil(it.next())
        XCTAssertNil(it.next())

        it.append(d1)
        // Since d1 itself is partial it should have nothing to return
        XCTAssertNil(it.next())
        XCTAssertNil(it.next())
        XCTAssertNil(it.next())
        XCTAssertNil(it.next())

        it.append(d2)
        XCTAssertEqual(it.next()?.count, 355)
        XCTAssertEqual(it.next()?.count, 223)
        XCTAssertNil(it.next())
        XCTAssertNil(it.next())
        XCTAssertNil(it.next())
        XCTAssertNil(it.next())

        it.append(d3)
        XCTAssertEqual(it.next()?.count, 358)
        XCTAssertNil(it.next())
        XCTAssertNil(it.next())
        XCTAssertNil(it.next())
    }

}

#if os(Linux)

extension RequestIteratorTests {
    static var allTests: [(String, (RequestIteratorTests) -> () throws -> Void)] {
        return [
            ("testIteratingMultipleRequestsAndHeaders", testIteratingMultipleRequestsAndHeaders),   
            ("testIteratingFullAndPartialRequestsWithoutCrash", testIteratingFullAndPartialRequestsWithoutCrash),   
            ("testIteratingByAppendingBuffers", testIteratingByAppendingBuffers),   
        ]
    }
}

#endif
