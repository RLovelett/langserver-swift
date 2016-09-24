import PackageDescription

let package = Package(
    name: "language-server-protocol-swift",
    dependencies: [
        .Package(url: "https://github.com/czechboy0/Socks.git", majorVersion: 0, minor: 12),
        .Package(url: "https://github.com/IBM-Swift/BlueSocket.git", majorVersion: 0, minor: 10)
    ]
)
