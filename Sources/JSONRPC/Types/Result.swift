//
//  Result.swift
//  langserver-swift
//
//  Created by Ryan Lovelett on 11/23/16.
//
//

public enum Result {
    case success(Messageable)
    case error(ServerError)
}
