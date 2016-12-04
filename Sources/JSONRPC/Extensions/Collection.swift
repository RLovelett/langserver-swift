//
//  Collection.swift
//  langserver-swift
//
//  Created by Ryan Lovelett on 12/3/16.
//
//

import Argo
import Ogra

public extension Collection where Iterator.Element: Encodable {

    func encode() -> JSON {
        let arr = self.map({ $0.encode() })
        return JSON.array(arr)
    }
    
}
