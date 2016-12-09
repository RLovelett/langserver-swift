import PackageDescription

let package = Package(
    name: "langserver-swift",
    targets: [
        Target(name: "JSONRPC"),
        Target(name: "LanguageServerProtocol", dependencies: ["JSONRPC"]),
        Target(name: "LanguageServer", dependencies: ["LanguageServerProtocol", "JSONRPC"])
    ],
    dependencies: [
        .Package(url: "https://github.com/RLovelett/SourceKitten.git", majorVersion: 0),
        .Package(url: "https://github.com/RLovelett/Argo.git", majorVersion: 4),
        .Package(url: "https://github.com/thoughtbot/Curry.git", majorVersion: 3)
    ]
)
