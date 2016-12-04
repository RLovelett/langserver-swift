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

* Swift Open Source `swift-DEVELOPMENT-SNAPSHOT-2016-12-01-a` toolchain (**Minimum REQUIRED for latest release**)

### macOS

* macOS 10.11.6 (*El Capitan*) or higher
* Xcode Version 8.2 beta (8C30a) or higher using one of the above toolchains (*Recommended*)

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
