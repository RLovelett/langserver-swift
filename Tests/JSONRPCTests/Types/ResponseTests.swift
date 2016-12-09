//
//  ResponseTests.swift
//  langserver-swift
//
//  Created by Ryan Lovelett on 11/21/16.
//
//

import Argo
import Foundation
@testable import JSONRPC
import XCTest

fileprivate func stringify(_ data: Data) -> String {
    return String(data: data, encoding: .utf8) ?? "Could not convert to UTF-8"
}

class ResponseTests: XCTestCase {

    func testSendingErrorMessage() {
        let request = Request.request(id: .number(1), method: "", params: JSON.null)
        let response = Response(to: request, is: PredefinedError.internalError)
        let message = stringify(response.data([ : ]))
        XCTAssert(message.contains("Content-Length: 108\r\n"))
        XCTAssert(message.contains("\"id\" : 1"))
    }
    
}
