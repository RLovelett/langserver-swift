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
        .package(url: "https://github.com/RLovelett/Argo.git", .branch("swift-4.1-macOS-and-linux")),
        .package(url: "https://github.com/RLovelett/Ogra.git", .branch("master")),
        .package(url: "https://github.com/thoughtbot/Curry.git", from: "4.0.0"),
        .package(url: "https://github.com/RLovelett/swift-package-manager.git", .branch("swift-4.1-branch")),
        .package(url: "https://github.com/felix91gr/Csdjournal.git", from: "1.0.1"),
    ],
    targets: [
        .target(
            name: "BaseProtocol",
            dependencies: [
                "Argo",
                "CSDJournal",
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
                "CSDJournal",
                "SourceKitter",
                "SwiftPM",
            ]
        ),
        .target(
            name: "LanguageServer",
            dependencies: [
                "BaseProtocol",
                "CSDJournal",
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
    ]
)
