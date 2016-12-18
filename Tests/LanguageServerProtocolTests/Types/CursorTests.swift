//
//  CursorTests.swift
//  langserver-swift
//
//  Created by Ryan Lovelett on 12/17/16.
//
//

@testable import LanguageServerProtocol
import XCTest

class CursorTests: XCTestCase {
    
    func testSystemSymbol() {
        let json = loadJSONFromFixture("system.json", in: "JSON/cursor")
        switch Cursor.decode(json) {
        case .success(let c):
            switch c.defined {
            case .local(_):
                XCTFail("Expected a system symbol.")
            case let .system(moduleName, groupName, isSystem):
                XCTAssertEqual(moduleName, "Swift")
                XCTAssertEqual(groupName, "String")
                XCTAssertEqual(isSystem, true)
            }
        case .failure(let e):
            XCTFail(e.description)
        }
    }

    func testModuleSymbol() {
        let json = loadJSONFromFixture("module.json", in: "JSON/cursor")
        switch Cursor.decode(json) {
        case .success(let c):
            switch c.defined {
            case let .local(filepath, offset, length):
                XCTAssertTrue(filepath.path.contains("main.swift"))
                XCTAssertEqual(offset, 5)
                XCTAssertEqual(length, 23)
            case .system(_):
                XCTFail("Expected a local symbol.")
            }
        case .failure(let e):
            XCTFail(e.description)
        }
    }
    
}
