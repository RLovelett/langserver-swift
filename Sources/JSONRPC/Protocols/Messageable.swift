//
//  Messageable.swift
//  langserver-swift
//
//  Created by Ryan Lovelett on 11/23/16.
//
//

import Foundation

public protocol Messageable {
    var message: [String : Any]? { get }
}
