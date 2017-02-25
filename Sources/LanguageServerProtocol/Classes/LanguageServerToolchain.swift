//
//  LanguageServerToolchain.swift
//  langserver-swift
//
//  Created by Ryan Lovelett on 3/14/17.
//
//

import Basic
import protocol Build.Toolchain
import enum Commands.Error
import protocol PackageLoading.ManifestResourceProvider
import POSIX

#if os(macOS)
    private let whichSwiftcArgs = ["xcrun", "--find", "swiftc"]
    private let whichClangArgs = ["xcrun", "--find", "clang"]
    private let whichDefaultSDKArgs = ["xcrun", "--sdk", "macosx", "--show-sdk-path"]
    private let whichPlatformPathArgs = ["xcrun", "--sdk", "macosx", "--show-sdk-platform-path"]
#else
    private let whichClangArgs = ["which", "clang"]
#endif

private func which(args: [String], problem: String) throws -> AbsolutePath {
    // No value in env, so search for `clang`.
    guard let foundPath = try? POSIX.popen(args).chomp(), !foundPath.isEmpty else {
        throw Error.invalidToolchain(problem: problem)
    }
    return AbsolutePath(foundPath)
}

struct LanguageServerToolchain: Toolchain, ManifestResourceProvider {
    /// Path of the `swiftc` compiler.
    public let swiftCompiler: AbsolutePath

    /// Path of the `clang` compiler.
    public let clangCompiler: AbsolutePath

    /// Path to llbuild.
    let llbuild: AbsolutePath

    /// Path to SwiftPM library directory containing runtime libraries.
    public let libDir: AbsolutePath

    /// Path of the default SDK (a.k.a. "sysroot"), if any.
    public let defaultSDK: AbsolutePath?

    /// Path of the `swiftc` compiler.
    public var swiftCompilerPath: AbsolutePath {
        return swiftCompiler
    }

    /// Path to SwiftPM library directory containing runtime libraries.
    public var libraryPath: AbsolutePath {
        return libDir
    }

#if os(macOS)
    /// Path to the sdk platform framework path.
    public let sdkPlatformFrameworksPath: AbsolutePath?

    public var clangPlatformArgs: [String] {
        var args = ["-arch", "x86_64", "-mmacosx-version-min=10.10", "-isysroot", defaultSDK!.asString]
        if let sdkPlatformFrameworksPath = sdkPlatformFrameworksPath {
            args += ["-F", sdkPlatformFrameworksPath.asString]
        }
        return args
    }
    public var swiftPlatformArgs: [String] {
        var args = ["-target", "x86_64-apple-macosx10.10", "-sdk", defaultSDK!.asString]
        if let sdkPlatformFrameworksPath = sdkPlatformFrameworksPath {
            args += ["-F", sdkPlatformFrameworksPath.asString]
        }
        return args
    }
#else
    let clangPlatformArgs: [String] = ["-fPIC"]
    let swiftPlatformArgs: [String] = []
#endif

    public init() throws {
        // Find the Swift compiler
        swiftCompiler = try which(args: whichSwiftcArgs, problem: "could not find `swiftc`")

        // Check that it's valid in the file system.
        // FIXME: We should also check that it resolves to an executable file
        //        (it could be a symlink to such as file).
        guard localFileSystem.exists(swiftCompiler) else {
            throw Error.invalidToolchain(problem: "could not find `swiftc` at expected path \(swiftCompiler.asString)")
        }

        let binDir = swiftCompiler.parentDirectory

        libDir = binDir.parentDirectory.appending(components: "lib", "swift", "pm")

        // Look for llbuild in bin dir.
        llbuild = binDir.appending(component: "swift-build-tool")
        guard localFileSystem.exists(llbuild) else {
            throw Error.invalidToolchain(problem: "could not find `llbuild` at expected path \(llbuild.asString)")
        }

        // Find the Clang compiler
        clangCompiler = try which(args: whichClangArgs, problem: "could not find `clang`")

        // Check that it's valid in the file system.
        // FIXME: We should also check that it resolves to an executable file
        //        (it could be a symlink to such as file).
        guard localFileSystem.exists(clangCompiler) else {
            throw Error.invalidToolchain(problem: "could not find `clang` at expected path \(clangCompiler.asString)")
        }

        // Find the default SDK (on macOS only).
      #if os(macOS)
        let sdk = try which(args: whichDefaultSDKArgs, problem: "could not find default SDK")

        // Verify that the sdk exists and is a directory
        guard localFileSystem.exists(sdk) && localFileSystem.isDirectory(sdk) else {
            throw Error.invalidToolchain(problem: "could not find default SDK at expected path \(sdk.asString)")
        }
        defaultSDK = sdk

        // Try to get the platform path.
        sdkPlatformFrameworksPath = (try? which(args: whichPlatformPathArgs, problem: "swallowed"))?
            .appending(components: "Developer", "Library", "Frameworks")
      #else
        defaultSDK = nil
      #endif
    }
}
