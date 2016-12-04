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
            let json: Any = try self.failableSend()
            return T.decode(JSON(json))
        } catch {
            return .customError(error.localizedDescription)
        }
    }

    func decode<T: Decodable>() -> Decoded<[T]> where T.DecodedType == T {
        do {
            let json: Any = try self.failableSend()
            let result: Decoded<[T]> = JSON(json) <|| "key.results"
            return result
        } catch {
            return .customError(error.localizedDescription)
        }
    }

}
