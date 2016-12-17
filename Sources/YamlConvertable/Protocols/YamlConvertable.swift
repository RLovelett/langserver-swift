//
//  YamlConvertable.swift
//  langserver-swift
//
//  Created by Ryan Lovelett on 12/18/16.
//
//

import Argo
import Yams

public protocol YamlConvertable {

    associatedtype DecodedType = Self

    static func decode(_ yaml: Node) -> Decoded<DecodedType>

}
