//
//  ServerError.swift
//  langserver-swift
//
//  Created by Ryan Lovelett on 11/22/16.
//
//

public protocol ServerError : Error {
    var code: Int { get }
    var message: String { get }
    var data: Any? { get }
}
