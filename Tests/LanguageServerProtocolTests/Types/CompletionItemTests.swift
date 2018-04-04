//
//  CompletionItemTests.swift
//  langserver-swift
//
//  Created by Ryan Lovelett on 12/2/16.
//
//

import Argo
import Foundation
@testable import LanguageServerProtocol
import Runes
import XCTest

class CompletionItemTests: XCTestCase {

    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    func testParseCompletionItems() {
        let json = loadJSONFromFixture("complete.json", in: "JSON/code-completion")
        let foo: Decoded<[CompletionItem]> = json <|| "key.results"

        switch foo {
        case .success(let bar):
            XCTAssertEqual(bar.count, 345)
        case .failure(let e):
            XCTFail(e.localizedDescription)
        }
    }

    func testKeywordCompletionItem() {
        let json = loadJSONFromFixture("import.json", in: "JSON/code-completion")
        let foo = CompletionItem.decode(json)
        switch foo {
        case .success(let item):
            XCTAssertEqual(item.kind, CompletionItemKind.Keyword)
            XCTAssertEqual(item.label, "import")
            XCTAssertEqual(item.detail, "import")
            XCTAssertNil(item.documentation)
        case .failure(let e):
            XCTFail(e.description)
        }
    }

    func testProtocolCompletionItem() {
        let json = loadJSONFromFixture("integer.json", in: "JSON/code-completion")
        let foo = CompletionItem.decode(json)
        switch foo {
        case .success(let item):
            XCTAssertEqual(item.kind, CompletionItemKind.Interface)
            XCTAssertEqual(item.label, "Integer")
            XCTAssertEqual(item.detail, "Integer")
            XCTAssertEqual(item.documentation, "A set of common requirements for Swift’s integer types.")
        case .failure(let e):
            XCTFail(e.description)
        }
    }

    func testConstructorCompletionItem() {
        let json = loadJSONFromFixture("constructor.json", in: "JSON/code-completion")
        let foo = CompletionItem.decode(json)
        switch foo {
        case .success(let item):
            XCTAssertEqual(item.kind, CompletionItemKind.Constructor)
            XCTAssertEqual(item.label, "(x: Int, y: String)")
            XCTAssertEqual(item.detail, "Test.Bar (x: Int, y: String)")
            XCTAssertNil(item.documentation)
        case .failure(let e):
            XCTFail(e.description)
        }
    }

}

#if os(Linux)

extension CompletionItemTests {
    static var allTests: [(String, (CompletionItemTests) -> () throws -> Void)] {
        return [
            ("testParseCompletionItems", testParseCompletionItems),
            ("testKeywordCompletionItem", testKeywordCompletionItem),    
            ("testProtocolCompletionItem", testProtocolCompletionItem),
            ("testConstructorCompletionItem", testConstructorCompletionItem),      
        ]
    }
}

#endif
