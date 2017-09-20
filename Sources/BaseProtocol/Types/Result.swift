//
//  Result.swift
//  langserver-swift
//
//  Created by Ryan Lovelett on 11/23/16.
//
//

import Ogra

public enum Result {
    case success(Ogra.Encodable)
    case error(ServerError)
}
