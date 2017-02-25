//
//  SwiftModuleTests.swift
//  langserver-swift
//
//  Created by Ryan Lovelett on 12/23/16.
//
//

import Argo
@testable import LanguageServerProtocol
@testable import YamlConvertable
import Yams
import XCTest

class SwiftModuleTests: XCTestCase {

    func testYamlLoading() {
        let fixture = getFixture("debug.yaml", in: "ValidLayouts/Simple/.build")!
        let str = try! String(contentsOf: fixture, encoding: .utf8)
        let yaml = try! Node(string: str)
        let foo: Decoded<Node> = flatReduce(["commands"], initial: yaml, combine: convertedYAML)
        let bar: Decoded<[SwiftModule]> = foo.flatMap(SwiftModule.decodeAndFilterFailed)
        switch bar {
        case .success(let modules):
            XCTAssertEqual(modules.count, 1)
        case .failure(let error):
            XCTFail(error.description)
        }
    }

}
