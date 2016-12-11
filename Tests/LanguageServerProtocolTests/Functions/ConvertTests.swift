//
//  ConvertTests.swift
//  langserver-swift
//
//  Created by Ryan Lovelett on 12/10/16.
//
//

@testable import LanguageServerProtocol
import XCTest

class ConvertTests: XCTestCase {

    func testExample() {
        XCTAssertEqual(convert("fatalError(<#T##message: String##String#>)").value, "fatalError({{1:message: String}})")
        XCTAssertEqual(convert("x: <#T##Int#>, y: <#T##String#>)").value, "x: {{1:Int}}, y: {{2:String}})")
        XCTAssertEqual(convert("debugPrint(<#T##items: Any...##Any#>, to: &<#T##Target#>)").value, "debugPrint({{1:items: Any...}}, to: &{{2:Target}})")
        XCTAssertEqual(convert("isKnownUniquelyReferenced(&<#T##object: T?##T?#>)").value, "isKnownUniquelyReferenced(&{{1:object: T?}})")
        XCTAssertEqual(convert("getVaList(<#T##args: [CVarArg]##[CVarArg]#>)").value, "getVaList({{1:args: [CVarArg]}})")
    }

}
