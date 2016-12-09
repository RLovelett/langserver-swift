//
//  LineCollectionTests.swift
//  langserver-swift
//
//  Created by Ryan Lovelett on 11/22/16.
//
//

import XCTest
@testable import LanguageServerProtocol

class LineCollectionTests: XCTestCase {

    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    func testOffsetCalculation() {
        guard let url = getFixture("main.swift.json", in: "JSON") else {
            XCTFail("Not a valid fixture.")
            return
        }

        do {
            let lc = try LineCollection(for: url)

            // All should be valid
            XCTAssertEqual(try lc.byteOffset(at: LinePosition(line: 0, character: 0)),      0)
            XCTAssertEqual(try lc.byteOffset(at: LinePosition(line: 2, character: 0)),     37)
            XCTAssertEqual(try lc.byteOffset(at: LinePosition(line: 97, character: 13)), 4222)
            XCTAssertEqual(try lc.byteOffset(at: LinePosition(line: 105, character: 1)), 4617)

            // All should be out of range
            XCTAssertNil(try lc.byteOffset(at: LinePosition(line: 0, character: 106)))
            XCTAssertNil(try lc.byteOffset(at: LinePosition(line: 106, character: 0)))
        } catch {
            XCTFail(error.localizedDescription)
        }
    }

    func testPositionCalculation() {
        guard let url = getFixture("main.swift.json", in: "JSON") else {
            XCTFail("Not a valid fixture.")
            return
        }

        do {
            let lc = try LineCollection(for: url)

            // All should be valid
            XCTAssertEqual(try lc.position(for:    0), LinePosition(line:   0, character:  0))
            XCTAssertEqual(try lc.position(for:   37), LinePosition(line:   2, character:  0))
            XCTAssertEqual(try lc.position(for: 4222), LinePosition(line:  97, character: 13))
            XCTAssertEqual(try lc.position(for: 4617), LinePosition(line: 105, character:  1))

            // All should be out of range
            XCTAssertNil(try lc.position(for: -100))
            XCTAssertNil(try lc.position(for: 4700))
        } catch {
            XCTFail(error.localizedDescription)
        }
    }

    func testSimpleBarSource() {
        guard let url = getFixture("bar.swift", in: "ValidLayouts/Simple/Sources") else {
            XCTFail("Not a valid fixture.")
            return
        }

        do {
            let lc = try LineCollection(for: url)
            XCTAssertEqual(lc.lines.count, 14)
        } catch {
            XCTFail(error.localizedDescription)
        }
    }

}
