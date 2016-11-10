//
//  EmptyMessage.swift
//  langserver-swift
//
//  Created by Ryan Lovelett on 11/21/16.
//
//

import JSONRPC

struct EmptyMessage : Messageable {

    var message: [String : Any]? { return .none }

}
