//
//  convertedYAML.swift
//  langserver-swift
//
//  Created by Ryan Lovelett on 12/18/16.
//
//

import Argo
import Yams

public func convertedYAML(_ yaml: Node, forKey key: String) -> Decoded<Node> {
    switch yaml {
    case .mapping(let o):
        guard let node = o.first(where: { $0.0 == key }) else {
            return .missingKey(key)
        }
        return pure(node.1)
    default: return .typeMismatch(expected: "Mapping", actual: "???")
    }
}
