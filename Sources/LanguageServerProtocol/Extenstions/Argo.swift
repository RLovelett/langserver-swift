//
//  Argo.swift
//  langserver-swift
//
//  Created by Ryan Lovelett on 11/21/16.
//
//

import Argo
import Foundation
import SourceKittenFramework

extension Request {

    func decode<T: Decodable>() -> Decoded<T> where T.DecodedType == T {
        do {
            let json = try self.sendAndReceiveJSON()
            return T.decode(JSON(json))
        } catch {
            return .customError(error.localizedDescription)
        }
    }

    func decode<T: Decodable>(key: String = "key.results") -> Decoded<[T]> where T.DecodedType == T {
        do {
            let json = try self.sendAndReceiveJSON()
            let result: Decoded<[T]> = JSON(json) <|| key
            return result
        } catch {
            return .customError(error.localizedDescription)
        }
    }

}
