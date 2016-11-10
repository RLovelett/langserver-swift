//
//  SwiftSourceTests.swift
//  langserver-swift
//
//  Created by Ryan Lovelett on 11/21/16.
//
//

import Foundation
@testable import LanguageServerProtocol
import XCTest

class SwiftSourceTests: XCTestCase {

    func testFindDefintion() {
        let m = URL(fileURLWithPath: "/Users/ryan/Desktop/Test/Sources/main.swift")
        let b = URL(fileURLWithPath: "/Users/ryan/Desktop/Test/Sources/bar.swift")
        let ms = SwiftSource(m)
        let bs = SwiftSource(b)
//        let e = ms!.defines("s:vV4main3Bar1ySS")
//        XCTAssertNotNil(e)
//        print(e!)
    }

    func testTwo() {
        let m = URL(fileURLWithPath: "/Users/ryan/Desktop/Test/Sources/main.swift")
        let b = URL(fileURLWithPath: "/Users/ryan/Desktop/Test/Sources/bar.swift")
        let ms = SwiftSource(m)
        let bs = SwiftSource(b)
//        XCTAssertNil(ms!.defines("s:V4main3Bar"))
//        let e = bs!.defines("s:V4main3Bar")
//        XCTAssertNotNil(e)
//        print(e!)
//        print(e!)
    }

}
