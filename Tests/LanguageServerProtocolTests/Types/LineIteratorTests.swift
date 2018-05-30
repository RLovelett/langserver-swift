//
//  LineIteratorTests.swift
//  LanguageServerProtocolTests
//
//  Created by Ryan Lovelett on 5/30/18.
//

import XCTest
@testable import LanguageServerProtocol

class LineIteratorTests: XCTestCase {

    let completeInner: String = {
        let url = getFixture("complete_inner.swift", in: "LineIterator")!
        return try! String(contentsOf: url)
    }()

    let cursorGetter: String = {
        let url = getFixture("cursor_getter.swift", in: "LineIterator")!
        return try! String(contentsOf: url)
    }()

    let simpleMain: String = {
        let url = getFixture("main.swift", in: "LineIterator")!
        return try! String(contentsOf: url)
    }()

    let simpleBar: String = {
        let url = getFixture("bar.swift", in: "LineIterator")!
        return try! String(contentsOf: url)
    }()

    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    func testCountLines() {
        XCTAssertEqual(Array(AnySequence { LineIterator(self.completeInner) }).count, 199)
        XCTAssertEqual(Array(AnySequence { LineIterator(self.cursorGetter) }).count, 25)
        XCTAssertEqual(Array(AnySequence { LineIterator(self.simpleMain) }).count, 2)
        XCTAssertEqual(Array(AnySequence { LineIterator(self.simpleBar) }).count, 15)
    }

    func testLineLayoutSimpleMain() {
        let seq = AnySequence { LineIterator(self.simpleMain) }
        let lines = Dictionary(seq.map { ($0.number, String(self.simpleMain[$0.start..<$0.end])) })
        let expectedLines = [
            0: "let x = Bar(x: 1, y: \"Ryan\")\n",
            1: "print(x.y)"
        ]
        XCTAssertEqual(lines, expectedLines)
    }

    func testLineLayoutSimpleBar() {
        let seq = AnySequence { LineIterator(self.simpleBar) }
        let lines = Dictionary(seq.map { ($0.number, String(self.simpleBar[$0.start..<$0.end])) })
        // Why are there 14 lines?
        // Why, is the last line an empty string?
        // If the last character in the document is a new line VS Code displays a zero length line
        let expectedLines = [
            0: "struct Bar {\n",
            1: "    let x: Int\n",
            2: "    let y: String\n",
            3: "}\n",
            4: "\n",
            5: "extension Bar {\n",
            6: "    func foo() -> Int {\n",
            7: "        return 1\n",
            8: "    }\n",
            9: "}\n",
            10: "\n",
            11: "private struct Blah {\n",
            12: "    let x: Bar\n",
            13: "}\n",
            14: ""
        ]
        XCTAssertEqual(lines, expectedLines)
    }

    func testLineContainsIndex() {
        var it = LineIterator(self.simpleBar)
        let firstLine = it.next()!
        let secondLine = it.next()!
        XCTAssertTrue(firstLine.contains(self.simpleBar.startIndex))
        XCTAssertTrue(firstLine.contains(firstLine.start))
        XCTAssertTrue(firstLine.contains(self.simpleBar.index(before: firstLine.end)))
        XCTAssertFalse(firstLine.contains(firstLine.end))
        XCTAssertFalse(firstLine.contains(secondLine.start))
        XCTAssertFalse(firstLine.contains(secondLine.end))
        XCTAssertFalse(firstLine.contains(self.simpleBar.endIndex))
    }

    func testLastLine() {
        for line in AnySequence({ LineIterator(self.simpleBar) }) {
            if line.number == 14 {
                XCTAssertTrue(line.last)
            } else {
                XCTAssertFalse(line.last)
            }
        }

        for line in AnySequence({ LineIterator(self.simpleMain) }) {
            if line.number == 1 {
                XCTAssertTrue(line.last)
            } else {
                XCTAssertFalse(line.last)
            }
        }
    }

}
