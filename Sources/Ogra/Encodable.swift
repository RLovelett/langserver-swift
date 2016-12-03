//
//  Encodable.swift
//  Ogra
//
//  Created by Craig Edwards on 27/07/2015.
//  Copyright © 2015 Craig Edwards. All rights reserved.
//

import Argo
import Foundation

public protocol Encodable {
	func encode() -> JSON
}

extension JSON: Encodable {
	public func encode() -> JSON {
		return self
	}
}

extension String: Encodable {
	public func encode() -> JSON {
		return .string(self)
	}
}

extension Bool: Encodable {
	public func encode() -> JSON {
		return .bool(self)
	}
}

extension Int: Encodable {
	public func encode() -> JSON {
		return .number(self as NSNumber)
	}
}

extension Double: Encodable {
	public func encode() -> JSON {
		return .number(self as NSNumber)
	}
}

extension Float: Encodable {
	public func encode() -> JSON {
		return .number(self as NSNumber)
	}
}

extension UInt: Encodable {
	public func encode() -> JSON {
		return .number(self as NSNumber)
	}
}

extension UInt64: Encodable {
	public func encode() -> JSON {
		return .number(NSNumber(value: self))
	}
}

extension Optional where Wrapped: Encodable {
	public func encode() -> JSON {
		switch self {
		case .none:        return .null
		case .some(let v): return v.encode()
		}
	}
}

extension Collection where Self: ExpressibleByDictionaryLiteral, Self.Key: ExpressibleByStringLiteral, Self.Value: Encodable, Iterator.Element == (key: Self.Key, value: Self.Value) {
	public func encode() -> JSON {
		var values = [String : JSON]()
		for (key, value) in self {
			values[String(describing: key)] = value.encode()
		}
		return .object(values)
	}
}

extension Optional where Wrapped: Collection & ExpressibleByDictionaryLiteral, Wrapped.Key: ExpressibleByStringLiteral, Wrapped.Value: Encodable, Wrapped.Iterator.Element == (key: Wrapped.Key, value: Wrapped.Value) {
	public func encode() -> JSON {
		return self.map { $0.encode() } ?? .null
	}
}

extension Collection where Self: ExpressibleByArrayLiteral, Self.Element: Encodable, Iterator.Element: Encodable {
	public func encode() -> JSON {
		return JSON.array(self.map { $0.encode() })
	}
}

extension Optional where Wrapped: Collection & ExpressibleByArrayLiteral, Wrapped.Element: Encodable, Wrapped.Iterator.Element == Wrapped.Element {
	public func encode() -> JSON {
		return self.map { $0.encode() } ?? .null
	}
}

extension Encodable where Self: RawRepresentable, Self.RawValue == String {
    public func encode() -> JSON {
        return .string(self.rawValue)
    }
}

extension Encodable where Self: RawRepresentable, Self.RawValue == Int {
    public func encode() -> JSON {
        return .number(self.rawValue as NSNumber)
    }
}

extension Encodable where Self: RawRepresentable, Self.RawValue == Double {
    public func encode() -> JSON {
        return .number(self.rawValue as NSNumber)
    }
}

extension Encodable where Self: RawRepresentable, Self.RawValue == Float {
    public func encode() -> JSON {
        return .number(self.rawValue as NSNumber)
    }
}

extension Encodable where Self: RawRepresentable, Self.RawValue == UInt {
    public func encode() -> JSON {
        return .number(self.rawValue as NSNumber)
    }
}

extension Encodable where Self: RawRepresentable, Self.RawValue == UInt64 {
    public func encode() -> JSON {
        return .number(NSNumber(value: self.rawValue))
    }
}

extension JSON {
	public func JSONObject() -> Any {
		switch self {
		case .null:              return NSNull()
		case .string(let value): return value
		case .number(let value): return value
		case .array(let array):  return array.map { $0.JSONObject() }
		case .bool(let value):   return value
		case .object(let object):
			var dict: [Swift.String : Any] = [:]
			for (key, value) in object {
                dict[key] = value.JSONObject()
			}
			return dict as Any
		}
	}
}
