// swift-tools-version:4.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "langserver-swift",
    products: [
        .executable(
            name: "langserver-swift",
            targets: [
                "BaseProtocol",
                "SourceKitter",
                "LanguageServerProtocol",
                "LanguageServer"
            ]
        )
    ],
    dependencies: [
        .package(url: "https://github.com/RLovelett/SourceKit.git", from: "1.0.0"),
        .package(url: "https://github.com/thoughtbot/Argo.git", from: "4.1.2"),
        .package(url: "https://github.com/edwardaux/Ogra.git", from: "4.1.2"),
        .package(url: "https://github.com/thoughtbot/Curry.git", from: "3.0.0"),
        .package(url: "https://github.com/RLovelett/swift-package-manager.git", .exact("3.1.1-beta.1")),
    ],
    targets: [
        .target(
            name: "BaseProtocol",
            dependencies: [
                "Argo",
                "Curry",
                "Ogra",
            ]
        ),
        .target(
            name: "SourceKitter",
            dependencies: [
                "Argo",
            ]
        ),
        .target(
            name: "LanguageServerProtocol",
            dependencies: [
                "BaseProtocol",
                "SourceKitter",
                "SwiftPM",
            ]
        ),
        .target(
            name: "LanguageServer",
            dependencies: [
                "BaseProtocol",
                "LanguageServerProtocol",
            ]
        ),
        .testTarget(
            name: "BaseProtocolTests",
            dependencies: [
                "BaseProtocol"
            ]
        ),
        .testTarget(
            name: "LanguageServerProtocolTests",
            dependencies: [
                "LanguageServerProtocol"
            ]
        ),
    ],
    swiftLanguageVersions: [3]
)
