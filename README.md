# Swift Language Server

![macOS](https://img.shields.io/badge/os-macOS-green.svg?style=flat)
![Linux](https://img.shields.io/badge/os-linux-green.svg?style=flat)
![Apache 2](https://img.shields.io/badge/license-Apache2-blue.svg?style=flat)
![](https://img.shields.io/badge/Swift-3.0-orange.svg?style=flat)

## Overview

A Swift implementation of the open [Language Server Protocol](https://github.com/Microsoft/language-server-protocol). The Language Server protocol is used between a tool (the client) and a language smartness provider (the server) to integrate features like auto complete, goto definition, find all references and alike into the tool.

Currently this implementation is used by [Swift for Visual Studio Code](https://github.com/RLovelett/vscode-swift).

## Prerequisites

### Swift

* The toolchain that comes with Xcode 8.3 beta 3 (`Apple Swift version 3.1 (swiftlang-802.0.36.2 clang-802.0.35)`)

### macOS

* macOS 10.12 (*Sierra*) or higher
* Xcode Version 8.3 beta 3 (8W132p) or higher using one of the above toolchains (*Recommended*)

### Linux

* **Coming Soon**

## Build

**NOTE**: You may first need to switch to using the Xcode beta (e.g., `sudo xcode-select -switch /Applications/Xcode-beta.app/Contents/Developer`)

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
