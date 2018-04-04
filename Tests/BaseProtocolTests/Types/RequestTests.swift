//
//  RequestTests.swift
//  langserver-swift
//
//  Created by Ryan Lovelett on 11/22/16.
//
//

import Argo
import BaseProtocol
import Curry
import Runes
import XCTest

private struct ArrayParams : Argo.Decodable {

    let x: [Int]

    static func decode(_ json: JSON) -> Decoded<ArrayParams> {
        let a: Decoded<[Int]> = [Int].decode(json)
        return curry(ArrayParams.init) <^> a
    }

}

fileprivate let invalid = loadFixture("invalid-json.txt", in: "JSON-RPC/JSON")
fileprivate let invalidRequest = loadFixture("invalid-request.txt", in: "JSON-RPC/JSON")
fileprivate let invalidHeader = loadFixture("invalid-header.txt", in: "JSON-RPC/JSON")
fileprivate let shutdown = loadFixture("shutdown.txt", in: "JSON-RPC/JSON")
fileprivate let valid = loadFixture("valid.txt", in: "JSON-RPC/JSON")
fileprivate let valid2 = loadFixture("valid-2.txt", in: "JSON-RPC/JSON")
fileprivate let validWithoutHeader = loadFixture("valid-without-header.txt", in: "JSON-RPC/JSON")
fileprivate let textDocumentDidOpen = loadFixture("textDocument-didOpen.txt", in: "JSON-RPC/JSON")

class RequestTests: XCTestCase {

    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    func testNotJSONContent() {
        let message = invalid!

        do {
            _ = try Request(message)
        } catch let error as PredefinedError {
            XCTAssertEqual(error, PredefinedError.parse)
        } catch {
            XCTFail("Expected a JSON parsing error.")
        }
    }

    func testInvalidRequestJSON() {
        let message = invalidRequest!

        do {
            _ = try Request(message)
        } catch let error as PredefinedError {
            XCTAssertEqual(error, PredefinedError.invalidRequest)
        } catch {
            XCTFail("Should have been an invalid request.")
        }
    }

    func testValidRequest() {
        let message = validWithoutHeader!

        do {
            _ = try Request(message)
        } catch {
            XCTFail("Should have been a valid Request.")
        }
    }

    func testInvalidHeader() {
        let message = invalidHeader!

        do {
            _ = try Request(message)
        } catch let error as PredefinedError {
            XCTAssertEqual(error, PredefinedError.parse)
        } catch {
            XCTFail("Expected a JSON parsing error.")
        }
    }

    func testValidHeaderAndRequest() {
        let message = valid!

        do {
            let r = try Request(message)
            XCTAssertEqual(r.method, "subtract")
            XCTAssertEqual(r.id, Request.Identifier.number(1))
        } catch {
            XCTFail("Should have been a valid Request.")
        }
    }

    func testParsingParameters() {
        let message = valid!

        do {
            let r = try Request(message)
            let p: ArrayParams = try r.parse()
            XCTAssertEqual(p.x, [42, 23])
        } catch {
            XCTFail("Should have been a valid Request.")
        }
    }

    func testParsingIncorrectParameters() {
        let message = valid2!

        do {
            let r = try Request(message)
            let _: ArrayParams = try r.parse()
            XCTFail("Expected the parameters to be invalid.")
        } catch let error as PredefinedError {
            XCTAssertEqual(error, PredefinedError.invalidParams)
        } catch {
            XCTFail("Expected the parameters to be invalid.")
        }
    }

    func testShutdownRequest() {
        let message = shutdown!

        do {
            let r = try Request(message)
            XCTAssertEqual(r.method, "shutdown")
            XCTAssertEqual(r.id, Request.Identifier.number(1))
        } catch {
            XCTFail("Should have been a valid Request.")
        }
    }

    func testTextDocumentDidOpen() {
        let message = textDocumentDidOpen!

        do {
            let r = try Request(message)
            XCTAssertEqual(r.method, "textDocument/didOpen")
            XCTAssertNil(r.id)
        } catch {
            XCTFail("Should have been a valid Request.")
        }
    }

}

#if os(Linux)

extension RequestTests {
    static var allTests: [(String, (RequestTests) -> () throws -> Void)] {
        return [
            ("testNotJSONContent", testNotJSONContent),   
            ("testInvalidRequestJSON", testInvalidRequestJSON),   
            ("testValidRequest", testValidRequest),

            ("testInvalidHeader", testInvalidHeader),   
            ("testValidHeaderAndRequest", testValidHeaderAndRequest),   
            ("testParsingParameters", testParsingParameters),   

            ("testParsingIncorrectParameters", testParsingIncorrectParameters),   
            ("testShutdownRequest", testShutdownRequest),   
            ("testTextDocumentDidOpen", testTextDocumentDidOpen),   
        ]
    }
}

#endif
