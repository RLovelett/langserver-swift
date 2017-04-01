# Swift Language Server

![macOS](https://img.shields.io/badge/os-macOS-green.svg?style=flat)
![Linux](https://img.shields.io/badge/os-linux-green.svg?style=flat)
![Apache 2](https://img.shields.io/badge/license-Apache2-blue.svg?style=flat)
![](https://img.shields.io/badge/Swift-3.1-orange.svg?style=flat)
[![Join the chat at https://gitter.im/langserver-swift](https://badges.gitter.im/langserver-swift/Lobby.svg)](https://gitter.im/langserver-swift?utm_source=badge&utm_medium=badge&utm_campaign=pr-badge&utm_content=badge)

## Overview

A Swift implementation of the open [Language Server Protocol](https://github.com/Microsoft/language-server-protocol). The Language Server protocol is used between a tool (the client) and a language smartness provider (the server) to integrate features like auto complete, goto definition, find all references and alike into the tool.

Currently this implementation is used by [Swift for Visual Studio Code](https://github.com/RLovelett/vscode-swift).

## Prerequisites

### Swift

* The toolchain that comes with Xcode 8.3 (`Apple Swift version 3.1 (swiftlang-802.0.48 clang-802.0.38)`)

### macOS

* macOS 10.12 (*Sierra*) or higher
* Xcode Version 8.3 (8E162) or higher using one of the above toolchains (*Recommended*)

### Linux

* **Coming Soon**

## Build

```
% cd <path-to-clone>
% swift build -Xswiftc -target -Xswiftc x86_64-apple-macosx10.11
```

or with Xcode

```
% cd <path-to-clone>
% swift package generate-xcodeproj --xcconfig-overrides settings.xcconfig
```

## Test

```
% cd <path-to-clone>
% swift test -Xswiftc -target -Xswiftc x86_64-apple-macosx10.11
```
