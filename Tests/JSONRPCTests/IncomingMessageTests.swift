import Foundation
@testable import JSONRPC
import XCTest

class IncomingMessageTests: XCTestCase {

    func testNotJSONContent() {
        let message = "{1}".data(using: .utf8)!

        do {
            _ = try IncomingMessage(message)
        } catch let error as PredefinedError {
            XCTAssertEqual(error, PredefinedError.Parse)
        } catch {
            XCTFail("Expected a JSON parsing error.")
        }
    }

    func testInvalidRequestJSON() {
        let message = "{\"jsonrpc\": \"2.0\", \"method\": 1, \"params\": \"bar\"}"
            .data(using: .utf8)!

        do {
            _ = try IncomingMessage(message)
        } catch let error as PredefinedError {
            XCTAssertEqual(error, PredefinedError.InvalidRequest)
        } catch {
            XCTFail("Should have been an invalid request.")
        }
    }

    func testValidRequest() {
        let message = "{\"jsonrpc\": \"2.0\", \"method\": \"subtract\", \"params\": [42, 23], \"id\": 1}"
            .data(using: .utf8)!

        do {
            _ = try IncomingMessage(message)
        } catch {
            XCTFail("Should have been a valid Request.")
        }
    }

    func testInvalidHeader() {
        let message = "Content-Length: 2\r\nD:\n{}"
            .data(using: .utf8)!

        do {
            _ = try IncomingMessage(message)
        } catch let error as PredefinedError {
            XCTAssertEqual(error, PredefinedError.Parse)
        } catch {
            XCTFail("Expected a JSON parsing error.")
        }
    }

    func testValidHeaderAndRequest() {
        let message = "Content-Length: 69\r\n\r\n{\"jsonrpc\": \"2.0\", \"method\": \"subtract\", \"params\": [42, 23], \"id\": 1}"
            .data(using: .utf8)!

        do {
            _ = try IncomingMessage(message)
        } catch {
            XCTFail("Should have been a valid Request.")
        }
    }

}
