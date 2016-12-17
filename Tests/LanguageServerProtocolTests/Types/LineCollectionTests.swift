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
        let url = getFixture("bar.swift", in: "ValidLayouts/Simple/Sources")!

        do {
            let lc = try LineCollection(for: url)

            XCTAssertEqual(lc.lines.count, 14)

            // All should be valid
            XCTAssertEqual(try lc.byteOffset(at: Position(line: 0,  character:  0)),   0) // First byte
            XCTAssertEqual(try lc.byteOffset(at: Position(line: 5,  character:  0)),  49)
            XCTAssertEqual(try lc.byteOffset(at: Position(line: 5,  character: 14)),  63)
            XCTAssertEqual(try lc.byteOffset(at: Position(line: 11, character:  8)), 123)
            XCTAssertEqual(try lc.byteOffset(at: Position(line: 13, character:  1)), 153) // Last byte

            // Off the "right" edge of the first line
            XCTAssertNil(try? lc.byteOffset(at: Position(line: 0, character: 13)))

            // Off the "bottom" edge of the document
            XCTAssertNil(try? lc.byteOffset(at: Position(line: 15, character: 0)))
        } catch {
            XCTFail(error.localizedDescription)
        }
    }

    func testPositionCalculation() {
        let url = getFixture("bar.swift", in: "ValidLayouts/Simple/Sources")!

        do {
            let lc = try LineCollection(for: url)

            // All should be valid
            XCTAssertEqual(try lc.position(for:   0), Position(line: 0,  character:  0))
            XCTAssertEqual(try lc.position(for:  49), Position(line: 5,  character:  0))
            XCTAssertEqual(try lc.position(for:  63), Position(line: 5,  character: 14))
            XCTAssertEqual(try lc.position(for: 123), Position(line: 11, character:  8))
            XCTAssertEqual(try lc.position(for: 153), Position(line: 13, character:  1))

            // All should be out of range
            XCTAssertNil(try? lc.position(for: -100))
            XCTAssertNil(try? lc.position(for: 4700))
        } catch {
            XCTFail(error.localizedDescription)
        }
    }

}
