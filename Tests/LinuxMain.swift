// Generated using Sourcery 0.13.1 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT

//
//  LinuxMain.swift
//  Tests
//
//  Created by Sourcery on 2018-05-27T21:24:16-0400.
//  sourcery --sources Tests --templates sourcery --output Tests --args testimports='@testable import BaseProtocolTests
//  @testable import LanguageServerProtocolTests'
//

import XCTest
@testable import BaseProtocolTests
@testable import LanguageServerProtocolTests

extension CompletionItemTests {
  static var allTests: [(String, (CompletionItemTests) -> () throws -> Void)] = [
    ("testParseCompletionItems", testParseCompletionItems),
    ("testKeywordCompletionItem", testKeywordCompletionItem),
    ("testProtocolCompletionItem", testProtocolCompletionItem),
    ("testConstructorCompletionItem", testConstructorCompletionItem)
  ]
}
extension ConvertTests {
  static var allTests: [(String, (ConvertTests) -> () throws -> Void)] = [
    ("testExample", testExample)
  ]
}
extension CursorTests {
  static var allTests: [(String, (CursorTests) -> () throws -> Void)] = [
    ("testSystemSymbol", testSystemSymbol),
    ("testModuleSymbol", testModuleSymbol)
  ]
}
extension DidChangeWatchedFilesParamsTests {
  static var allTests: [(String, (DidChangeWatchedFilesParamsTests) -> () throws -> Void)] = [
    ("testCreatedFile", testCreatedFile)
  ]
}
extension HeaderTests {
  static var allTests: [(String, (HeaderTests) -> () throws -> Void)] = [
    ("testHeaderWithNumericContentLength", testHeaderWithNumericContentLength),
    ("testHeaderWithoutContentLength", testHeaderWithoutContentLength),
    ("testHeaderWithMultipleFields", testHeaderWithMultipleFields)
  ]
}
extension LineCollectionTests {
  static var allTests: [(String, (LineCollectionTests) -> () throws -> Void)] = [
    ("testOffsetCalculation", testOffsetCalculation),
    ("testPositionCalculation", testPositionCalculation),
    ("testSourceWithoutTrailingNewLine", testSourceWithoutTrailingNewLine)
  ]
}
extension RequestIteratorTests {
  static var allTests: [(String, (RequestIteratorTests) -> () throws -> Void)] = [
    ("testIteratingMultipleRequestsAndHeaders", testIteratingMultipleRequestsAndHeaders),
    ("testIteratingFullAndPartialRequestsWithoutCrash", testIteratingFullAndPartialRequestsWithoutCrash),
    ("testIteratingByAppendingBuffers", testIteratingByAppendingBuffers)
  ]
}
extension RequestTests {
  static var allTests: [(String, (RequestTests) -> () throws -> Void)] = [
    ("testNotJSONContent", testNotJSONContent),
    ("testInvalidRequestJSON", testInvalidRequestJSON),
    ("testValidRequest", testValidRequest),
    ("testInvalidHeader", testInvalidHeader),
    ("testValidHeaderAndRequest", testValidHeaderAndRequest),
    ("testParsingParameters", testParsingParameters),
    ("testParsingIncorrectParameters", testParsingIncorrectParameters),
    ("testShutdownRequest", testShutdownRequest),
    ("testTextDocumentDidOpen", testTextDocumentDidOpen)
  ]
}
extension ResponseTests {
  static var allTests: [(String, (ResponseTests) -> () throws -> Void)] = [
    ("testSendingErrorMessage", testSendingErrorMessage)
  ]
}
extension SwiftModuleTests {
  static var allTests: [(String, (SwiftModuleTests) -> () throws -> Void)] = [
  ]
}
extension SwiftSourceTests {
  static var allTests: [(String, (SwiftSourceTests) -> () throws -> Void)] = [
    ("testFindDefintion", testFindDefintion),
    ("testTwo", testTwo)
  ]
}
extension URLTests {
  static var allTests: [(String, (URLTests) -> () throws -> Void)] = [
    ("testDecodeDirectory", testDecodeDirectory),
    ("testDecodeFile", testDecodeFile)
  ]
}
extension WorkspaceTests {
  static var allTests: [(String, (WorkspaceTests) -> () throws -> Void)] = [
    ("testWorkspace", testWorkspace)
  ]
}

// swiftlint:disable trailing_comma
XCTMain([
  testCase(CompletionItemTests.allTests),
  testCase(ConvertTests.allTests),
  testCase(CursorTests.allTests),
  testCase(DidChangeWatchedFilesParamsTests.allTests),
  testCase(HeaderTests.allTests),
  testCase(LineCollectionTests.allTests),
  testCase(RequestIteratorTests.allTests),
  testCase(RequestTests.allTests),
  testCase(ResponseTests.allTests),
  testCase(SwiftModuleTests.allTests),
  testCase(SwiftSourceTests.allTests),
  testCase(URLTests.allTests),
  testCase(WorkspaceTests.allTests),
])
// swiftlint:enable trailing_comma
