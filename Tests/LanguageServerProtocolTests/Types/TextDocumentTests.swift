//
//  TextDocumentTests.swift
//  langserver-swift
//
//  Created by Ryan Lovelett on 11/21/16.
//
//

import Foundation
@testable import LanguageServerProtocol
import XCTest

class TextDocumentTests: XCTestCase {

    func testCompleteInner() {
        let m = getFixture("complete_inner.swift", in: "LineIterator")!
        let ms = TextDocument(m)!
        let conversions = [
            // resolveFromLineCol(26, 11) => 455
            455: Position(line: 25, character: 10),
            // resolveFromLineCol(29, 9) => 491
            491: Position(line: 28, character: 8),
        ]
        for conversion in conversions {
            XCTAssertEqual(try ms.byteOffset(at: conversion.value), conversion.key)
            XCTAssertEqual(try ms.position(for: conversion.key), conversion.value)
        }
    }

    func testCusorGetter() {
        let m = getFixture("cursor_getter.swift", in: "LineIterator")!
        let ms = TextDocument(m)!

        let conversions = [
            // resolveFromLineCol(1, 1) => 0
            0: Position(line: 0, character: 0),
            // RUN: %sourcekitd-test -req=cursor -pos=1:15 %s -- %s | %FileCheck %s
            // resolveFromLineCol(1, 15) => 14
            14: Position(line: 0, character: 14),
            // RUN: %sourcekitd-test -req=cursor -pos=1:17 %s -- %s | %FileCheck %s
            // resolveFromLineCol(1, 17) => 16
            16: Position(line: 0, character: 16),
            // resolveFromLineCol(1, 30) => 29
            29: Position(line: 0, character: 29),
            // RUN: %sourcekitd-test -req=cursor -pos=2:15 %s -- %s | %FileCheck %s
            // resolveFromLineCol(2, 15) => 44
            44: Position(line: 1, character: 14),
            // RUN: %sourcekitd-test -req=cursor -pos=2:17 %s -- %s | %FileCheck %s
            // resolveFromLineCol(2, 17) => 46
            46: Position(line: 1, character: 16),
            // RUN: %sourcekitd-test -req=cursor -pos=2:21 %s -- %s | %FileCheck %s
            // resolveFromLineCol(2, 21) => 50
            50: Position(line: 1, character: 20),
            // RUN: %sourcekitd-test -req=cursor -pos=2:23 %s -- %s | %FileCheck %s
            // resolveFromLineCol(2, 23) => 52
            52: Position(line: 1, character: 22),
            // RUN: %sourcekitd-test -req=cursor -pos=3:15 %s -- %s | %FileCheck %s
            // resolveFromLineCol(3, 15) => 82
            82: Position(line: 2, character: 14),
            // RUN: %sourcekitd-test -req=cursor -pos=3:17 %s -- %s | %FileCheck %s
            // resolveFromLineCol(3, 17) => 84
            84: Position(line: 2, character: 16),
            // RUN: %sourcekitd-test -req=cursor -pos=3:21 %s -- %s | %FileCheck %s
            // resolveFromLineCol(3, 21) => 88
            88: Position(line: 2, character: 20),
            // RUN: %sourcekitd-test -req=cursor -pos=3:23 %s -- %s | %FileCheck %s
            // resolveFromLineCol(3, 23) => 90
            90: Position(line: 2, character: 22),
            // RUN: %sourcekitd-test -req=cursor -pos=3:37 %s -- %s | %FileCheck %s
            // resolveFromLineCol(3, 37) => 104
            104: Position(line: 2, character: 36),
            // RUN: %sourcekitd-test -req=cursor -pos=3:41 %s -- %s | %FileCheck %s
            // resolveFromLineCol(3, 41) => 108
            108: Position(line: 2, character: 40),
            // RUN: %sourcekitd-test -req=cursor -pos=6:29 %s -- %s | %FileCheck %s
            // resolveFromLineCol(6, 29) => 154
            154: Position(line: 5, character: 28),
            // RUN: %sourcekitd-test -req=cursor -pos=6:31 %s -- %s | %FileCheck %s
            // resolveFromLineCol(6, 31) => 156
            156: Position(line: 5, character: 30)
        ]
        for conversion in conversions {
            XCTAssertEqual(try ms.byteOffset(at: conversion.value), conversion.key)
            XCTAssertEqual(try ms.position(for: conversion.key), conversion.value)
        }

        XCTAssertThrowsError(try ms.byteOffset(at: Position(line: 0, character: 30)))
        XCTAssertThrowsError(try ms.byteOffset(at: Position(line: 25, character: 1)))
    }

    func testSimpleBar() {
        let url = getFixture("bar.swift", in: "ValidLayouts/Simple/Sources")!
        let ms = TextDocument(url)!

        let conversions = [
            0: Position(line: 0, character: 0),
            12: Position(line: 0, character: 12),
            13: Position(line: 1, character: 0),
            49: Position(line: 5, character: 0),
            63: Position(line: 5, character: 14),
            123: Position(line: 11, character: 8),
            153: Position(line: 13, character: 1),
            154: Position(line: 14, character: 0)
        ]
        for conversion in conversions {
            XCTAssertEqual(try ms.byteOffset(at: conversion.value), conversion.key)
            XCTAssertEqual(try ms.position(for: conversion.key), conversion.value)
        }

        // Off the right "edge" of the line
        XCTAssertThrowsError(try ms.byteOffset(at: Position(line: 0, character: 13)))
        XCTAssertThrowsError(try ms.byteOffset(at: Position(line: 1, character: 15)))
        XCTAssertThrowsError(try ms.byteOffset(at: Position(line: 2, character: 18)))
        XCTAssertThrowsError(try ms.byteOffset(at: Position(line: 3, character: 2)))
        XCTAssertThrowsError(try ms.byteOffset(at: Position(line: 4, character: 1)))
        XCTAssertThrowsError(try ms.byteOffset(at: Position(line: 5, character: 16)))
        XCTAssertThrowsError(try ms.byteOffset(at: Position(line: 6, character: 24)))
        XCTAssertThrowsError(try ms.byteOffset(at: Position(line: 7, character: 17)))
        XCTAssertThrowsError(try ms.byteOffset(at: Position(line: 8, character: 6)))
        XCTAssertThrowsError(try ms.byteOffset(at: Position(line: 9, character: 2)))
        XCTAssertThrowsError(try ms.byteOffset(at: Position(line: 10, character: 1)))
        XCTAssertThrowsError(try ms.byteOffset(at: Position(line: 11, character: 22)))
        XCTAssertThrowsError(try ms.byteOffset(at: Position(line: 12, character: 15)))
        XCTAssertThrowsError(try ms.byteOffset(at: Position(line: 13, character: 2)))
        XCTAssertThrowsError(try ms.byteOffset(at: Position(line: 14, character: 1)))

        // Off the "bottom" edge of the document
        XCTAssertThrowsError(try ms.byteOffset(at: Position(line: 15, character: 0)))
    }

    func testSimpleMain() {
        let url = getFixture("main.swift", in: "ValidLayouts/Simple/Sources")!
        let lc = TextDocument(url)!

        XCTAssertEqual(try lc.byteOffset(at: Position(line: 1, character:  3)), 32)
        XCTAssertEqual(try lc.byteOffset(at: Position(line: 1, character:  9)), 38)
        XCTAssertEqual(try lc.byteOffset(at: Position(line: 1, character: 10)), 39)

        // Of the right "edge" of the line
        XCTAssertThrowsError(try lc.byteOffset(at: Position(line: 1, character:  11)))

        XCTAssertThrowsError(try lc.position(for: -1))
    }

}
