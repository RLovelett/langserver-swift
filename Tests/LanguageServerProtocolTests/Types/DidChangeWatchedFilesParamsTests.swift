//
//  DidChangeWatchedFilesParamsTests.swift
//  langserver-swift
//
//  Created by Ryan Lovelett on 12/17/16.
//
//

@testable import LanguageServerProtocol
import XCTest

class DidChangeWatchedFilesParamsTests: XCTestCase {
    
    func testCreatedFile() {
        let json = loadJSONFromFixture("workspace-didChangeWatchedFiles-created.json", in: "JSON-RPC/JSON")
        switch DidChangeWatchedFilesParams.decode(json) {
        case .success(let params):
            XCTAssertEqual(params.changes.first?.type, FileChangeType.Created)
        case .failure(let error):
            XCTFail(error.description)
        }
    }
    
}
