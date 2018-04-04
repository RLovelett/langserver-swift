//
//  URLTests.swift
//  langserver-swift
//
//  Created by Ryan Lovelett on 12/24/16.
//
//

import Argo
@testable import LanguageServerProtocol
import XCTest

class URLTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    func testDecodeDirectory() {
        continueAfterFailure = false
        func test(_ str: String, _ expected: String? = nil) {
            let json = JSON.string(str)
            switch URL.decode(json) {
            case .success(let url):
                XCTAssertEqual(url, URL(fileURLWithPath: expected ?? str, isDirectory: true))
            case .failure(let error):
                XCTFail(error.description)
            }
        }
        test("/Users/ryan/Desktop/foo/bar")
        test("/Users/ryan/Desktop/foo/bar/")
        test("file:///Users/ryan/Desktop/foo/bar",  "/Users/ryan/Desktop/foo/bar")
        test("file:///Users/ryan/Desktop/foo/bar/", "/Users/ryan/Desktop/foo/bar")
    }

    func testDecodeFile() {
        continueAfterFailure = false
        func test(_ str: String, _ expected: String? = nil) {
            let json = JSON.string(str)
            switch URL.decode(json) {
            case .success(let url):
                XCTAssertEqual(url, URL(fileURLWithPath: expected ?? str, isDirectory: false))
            case .failure(let error):
                XCTFail(error.description)
            }
        }
        test("/Users/ryan/Desktop/foo.swift")
        test("/Users/ryan/Desktop/foo/bar.swift")
        test("file:///Users/ryan/Desktop/foo.swift",  "/Users/ryan/Desktop/foo.swift")
        test("file:///Users/ryan/Desktop/foo/bar.swift", "/Users/ryan/Desktop/foo/bar.swift")
    }
    
}

#if os(Linux)

extension URLTests {
    static var allTests: [(String, (URLTests) -> () throws -> Void)] {
        return [
            ("testDecodeDirectory", testDecodeDirectory),
            ("testDecodeFile", testDecodeFile),      
        ]
    }
}

#endif
