import Foundation
@testable import JSONRPC
import XCTest

class OutgoingMessageTests: XCTestCase {

    func testSendingErrorMessage() {
        let result = Response.Result.Error(PredefinedError.InternalError)
        let response = Response(to: RequestID.Number(1), result: result)
        let message = OutgoingMessage(header: [ : ], content: response).description
        XCTAssert(message.contains("Content-Length: 108\r\n"))
        XCTAssert(message.contains("\"id\" : 1"))
    }
    
}
