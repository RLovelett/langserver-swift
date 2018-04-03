//
//  Optional.swift
//  SourceKitter
//
//  Created by Ryan Lovelett on 4/3/18.
//

#if swift(>=4.2)
#else
extension Optional: Hashable where Wrapped: Hashable {
    /// The hash value for the optional instance.
    ///
    /// Two optionals that are equal will always have equal hash values.
    ///
    /// Hash values are not guaranteed to be equal across different executions of
    /// your program. Do not save hash values to use during a future execution.
    @_inlineable
    public var hashValue: Int {
        switch self {
        case .none:
            return 0
        case .some(let wrapped):
            return 1 ^ wrapped.hashValue
        }
    }
}
#endif
