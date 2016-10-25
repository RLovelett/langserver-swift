//
//  Dictionary.swift
//  VHS
//
//  Created by Ryan Lovelett on 7/13/16.
//  Copyright © 2016 Ryan Lovelett. All rights reserved.
//

import Foundation

extension Dictionary {
    /// This extension may eventually become part of the stdlib. It has been proposed as SE-100.
    ///
    /// Creates a new dictionary using the key/value pairs in the given sequence.
    ///
    /// - Parameter sequence:  A sequence of `(Key, Value)` tuples, where the type `Key` conforms to
    ///   the `Hashable` protocol.
    /// - Returns: A new dictionary initialized with the elements of `sequence`. If `Key` is
    ///   duplicated then the last value encountered will be the value in the dictionary.
    ///
    /// - Remark: This extension was initially based on the code provided for Swift-Evolution #100
    ///   (SE-100). However, that initializer is failable. Since we do not care about duplicates or
    ///   failures on duplicates that part of the `for-in` loop has been removed. This increases our
    ///   code-coverage amount without having to add and maintain a test.
    ///
    /// - SeeAlso: [SE-100: Add sequence-based initializers and merge methods to Dictionary](https://github.com/apple/swift-evolution/blob/8f53b7f467d4ebee6891577311ca70715b4c9834/proposals/0100-add-sequence-based-init-and-merge-to-dictionary.md)
    // swiftlint:disable:previous line_length
    init<S: Sequence>(_ sequence: S) where S.Iterator.Element == Element {
        self = Dictionary(minimumCapacity: sequence.underestimatedCount)
        for (key, value) in sequence {
            let _ = self.updateValue(value, forKey: key)
        }
    }
}
