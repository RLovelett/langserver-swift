//
//  SourceKit.swift
//  langserver-swift
//
//  Created by Ryan Lovelett on 11/21/16.
//
//

import Argo
import Foundation
#if os(macOS) || os(iOS) || os(watchOS) || os(tvOS)
import os.log
#endif
import SourceKit

#if os(macOS) || os(iOS) || os(watchOS) || os(tvOS)
private let log = OSLog(subsystem: "me.lovelett.langserver-swift", category: "SourceKit")
#endif

/// Provides a convience wrapper to safely make calls to SourceKit.
public final class SourceKit {

    /// Initialize and maintain a connection with SourceKit for the lifetime of an instance.
    ///
    /// There should only be one of these in the entire application.
    public class Session {

        /// Create a SourceKit session.
        public init() {
            sourcekitd_initialize()
        }

        /// Exit the SourceKit session.
        deinit {
            sourcekitd_shutdown()
        }

    }

    /// Convert Swift native types, e.g., String, Int64, URL, to their SourceKit native types.
    ///
    /// For example, assume a SourceKit request has an option that has a key, `key.sourcetext`, that takes
    /// a `String`. To make such an argument would be to call `Option(uid: "key.sourcetext", value: "Text")`.
    ///
    /// When you then need to send those properties to SourceKit use the `key` and `obj` properties.
    ///
    /// - Warning: The memory returned from this stuff leaks like a sive.
    /// - TODO: Fix all the memory leaks in this type.
    struct Option<T: SourceKitRequestable> {

        private let uid: String

        private let value: T

        init(uid: String, value: T) {
            self.uid = uid
            self.value = value
        }

        var key: sourcekitd_uid_t? {
            return sourcekitd_uid_get_from_cstr(uid)
        }

        var obj: sourcekitd_object_t? {
            return value.sourceKitObject
        }

    }

    private let obj: sourcekitd_object_t?

    /// Create a SourceKit request object from the options and build arguments provided.
    ///
    /// - Parameters:
    ///   - options: A dictionary containing the key value pairs of options to be sent with a request.
    ///   - args: The build arguments array.
    private init(_ options: [sourcekitd_uid_t? : sourcekitd_object_t?], _ args: [String]) {
        var dict = options
        dict[sourcekitd_uid_get_from_cstr("key.compilerargs")] = args.sourceKit
        var keys = Array(dict.keys)
        var values = Array(dict.values)
        obj = sourcekitd_request_dictionary_create(&keys, &values, dict.count)
    }

    deinit {
        obj.map { sourcekitd_request_release($0) }
    }

    /// Issue the request to SourceKit and parse the response into JSON.
    ///
    /// - Returns: A monad that contains the response from SourceKit.
    public func request() -> Decoded<JSON> {
        #if os(macOS) || os(iOS) || os(watchOS) || os(tvOS)
            let descPtr = obj.flatMap { sourcekitd_request_description_copy($0) }
            let description = descPtr
                .map({ (UnsafeMutableRawPointer($0), Int(strlen($0))) })
                .flatMap({ String(bytesNoCopy: $0.0, length: $0.1, encoding: .utf8, freeWhenDone: true) })!
            os_log("%{public}@", log: log, type: .default, description)
        #endif

        let response = sourcekitd_send_request_sync(obj!)!
        defer {
            sourcekitd_response_dispose(response)
        }
        if sourcekitd_response_is_error(response) {
            let error = SourceKitError(response)
            return Decoded<JSON>.customError(error.description)
        }
        let info = sourcekitd_response_get_value(response)
        let ptr = sourcekitd_variant_json_description_copy(info)
        let json = Decoded<UnsafeMutablePointer<Int8>>.fromOptional(ptr)
            // ⚠️ The documentation for `sourcekitd_variant_json_description_copy` says: ⚠️
            // This string should be disposed of with `free` when done.
            // Thus the `Data` initializer with custom deallocator is used
            .map({ Data(bytesNoCopy: UnsafeMutableRawPointer($0), count: Int(strlen($0)), deallocator: .free) })
            .flatMap({ Decoded<Any>.fromOptional(try? JSONSerialization.jsonObject(with: $0, options: [])) })
            .map(JSON.init)
        return json
    }

    /// SourceKit is capable of providing information about a specific symbol at a specific cursor, or offset, position
    /// in a document.
    ///
    /// To gather documentation, SourceKit must be given either the name of a module, the path to a file, or some text.
    ///
    /// - Note: The source file is ignored when source text is also provided, and both of those keys are ignored if a
    /// module name is provided.
    ///
    /// - SeeAlso: SourceKit Docs: [Cursor Info](https://github.com/apple/swift/blob/
    ///   cf5f91437754568efce7a52e7ffb1794d2a6cc60/tools/SourceKit/docs/Protocol.md#cursor-info)
    ///
    /// - Parameters:
    ///   - text: Source contents.
    ///   - file: Absolute path to the file.
    ///   - offset: Byte offset of code point inside the source contents.
    ///   - args: Array of zero or more strings for the compiler arguments, e.g., `["-sdk", "/path/to/sdk"]`. If source
    ///   file is provided, this array must include the path to that file.
    /// - Returns: A `SourceKit` instance that can be used to request a JSON formatted response.
    public static func CursorInfo(source text: String, source file: URL, offset: Int64, args: [String]) -> SourceKit {
        let request = SourceKit.Option(uid: "key.request", value: RequestType.cursorInfo)
        let sourceText = SourceKit.Option(uid: "key.sourcetext", value: text)
        let sourceFile = SourceKit.Option(uid: "key.sourcefile", value: file)
        let offset = SourceKit.Option(uid: "key.offset", value: offset)
        let options: [sourcekitd_uid_t? : sourcekitd_object_t?] = [
            request.key: request.obj,
            sourceText.key: sourceText.obj,
            sourceFile.key: sourceFile.obj,
            offset.key: offset.obj
        ]
        return SourceKit(options, args)
    }

    /// SourceKit is capable of providing code completion suggestions. To do so, it must be given either the path to a
    /// file, or some text.
    ///
    /// - Note: The source file is ignored when source text is also provided.
    ///
    /// - SeeAlso: SourceKit Docs: [Code Completion](https://github.com/apple/swift/blob/
    ///   cf5f91437754568efce7a52e7ffb1794d2a6cc60/tools/SourceKit/docs/Protocol.md#code-completion)
    ///
    /// - Parameters:
    ///   - text: Source contents
    ///   - file: Absolute path to the file
    ///   - offset: Byte offset of code-completion point inside the source contents
    ///   - args: Array of zero or more strings for the compiler arguments, e.g., `["-sdk", "/path/to/sdk"]`. If source
    ///   file is provided, this array must include the path to that file.
    /// - Returns: A `SourceKit` instance that can be used to request a JSON formatted response.
    public static func CodeComplete(source text: String, source file: URL, offset: Int64, args: [String]) -> SourceKit {
        let request = SourceKit.Option(uid: "key.request", value: RequestType.codeComplete)
        let sourceText = SourceKit.Option(uid: "key.sourcetext", value: text)
        let sourceFile = SourceKit.Option(uid: "key.sourcefile", value: file)
        let offset = SourceKit.Option(uid: "key.offset", value: offset)
        let options: [sourcekitd_uid_t? : sourcekitd_object_t?] = [
            request.key: request.obj,
            sourceText.key: sourceText.obj,
            sourceFile.key: sourceFile.obj,
            offset.key: offset.obj
        ]
        return SourceKit(options, args)
    }

}
