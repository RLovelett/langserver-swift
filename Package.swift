import PackageDescription

let package = Package(
    name: "langserver-swift",
    targets: [
        Target(name: "JSONRPC"),
        Target(name: "YamlConvertable"),
        Target(name: "LanguageServerProtocol", dependencies: ["YamlConvertable", "JSONRPC"]),
        Target(name: "LanguageServer", dependencies: ["LanguageServerProtocol", "JSONRPC"])
    ],
    dependencies: [
        .Package(url: "https://github.com/RLovelett/SourceKitten.git", majorVersion: 0),
        .Package(url: "https://github.com/jpsim/Yams.git", Version(0, 1, 4)),
        .Package(url: "https://github.com/thoughtbot/Argo.git", majorVersion: 4),
        .Package(url: "https://github.com/edwardaux/Ogra.git", majorVersion: 4),
        .Package(url: "https://github.com/thoughtbot/Curry.git", majorVersion: 3)
    ]
)

products.append(
    Product(
        name: "langserver-swift",
        type: .Executable,
        modules: ["LanguageServer"]
    )
)
