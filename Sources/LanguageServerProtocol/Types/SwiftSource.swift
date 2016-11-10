//
//  SwiftSource.swift
//  langserver-swift
//
//  Created by Ryan Lovelett on 10/25/16.
//
//

import Foundation
import SourceKittenFramework
import Argo

struct SwiftSource {

    let file: URL

    let lines: LineCollection

    init?(_ file: URL) {
        self.file = file
        guard let lines = try? LineCollection(for: file) else { return nil }
        self.lines = lines
    }

}
