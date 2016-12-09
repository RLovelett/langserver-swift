//
//  Fixtures.swift
//  langserver-swift
//
//  Created by Ryan Lovelett on 11/21/16.
//
//

import Argo
import Foundation

fileprivate func loadData(_ url: URL) -> Data? {
    return try? Data(contentsOf: url, options: .mappedIfSafe)
}

fileprivate func serializeJSON(_ data: Data) -> Any? {
    return try? JSONSerialization.jsonObject(with: data, options: [])
}

let root: URL = {
    var u = URL(fileURLWithPath: #file, isDirectory: false).deletingLastPathComponent()
    while u.lastPathComponent != "langserver-swift" {
        u.deleteLastPathComponent()
    }
    return u
}()

func getFixture(subdirectory: String) -> URL {
    return root
        .appendingPathComponent("Fixtures", isDirectory: true)
        .appendingPathComponent(subdirectory, isDirectory: true)
}

func getFixture(_ named: String, in subdirectory: String) -> URL? {
    return getFixture(subdirectory: subdirectory)
        .appendingPathComponent(named, isDirectory: false)
}

func loadFixture(_ named: String, in subdirectory: String) -> Data? {
    return getFixture(named, in: subdirectory).flatMap(loadData)
}

func loadJSONFromFixture(_ named: String, in subdirectory: String = "JSON") -> JSON {
    return loadFixture(named, in: subdirectory)
        .flatMap(serializeJSON)
        .map({ JSON($0) }) ?? .null
}

