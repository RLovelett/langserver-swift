//
//  ToolWorkspaceDelegate.swift
//  langserver-swift
//
//  Created by Ryan Lovelett on 4/16/17.
//
//

import os.log
import Workspace

class ToolWorkspaceDelegate: WorkspaceDelegate {

    func fetchingMissingRepositories(_ urls: Set<String>) {
    }

    func fetching(repository: String) {
        if #available(macOS 10.12, *) {
            let log = OSLog(subsystem: "me.lovelett.langserver-swift", category: "ToolWorkspaceDelegate")
            os_log("Fetching: %{public}@", log: log, type: .default, repository)
        }
    }

    func cloning(repository: String) {
        if #available(macOS 10.12, *) {
            let log = OSLog(subsystem: "me.lovelett.langserver-swift", category: "ToolWorkspaceDelegate")
            os_log("Cloning: %{public}@", log: log, type: .default, repository)
        }
    }

    func checkingOut(repository: String, at reference: String) {
        // FIXME: This is temporary output similar to old one, we will need to figure
        // out better reporting text.
        if #available(macOS 10.12, *) {
            let log = OSLog(subsystem: "me.lovelett.langserver-swift", category: "ToolWorkspaceDelegate")
            os_log("Resolving %{public}@ at %{public}@", log: log, type: .default, repository, reference)
        }
    }

    func removing(repository: String) {
        if #available(macOS 10.12, *) {
            let log = OSLog(subsystem: "me.lovelett.langserver-swift", category: "ToolWorkspaceDelegate")
            os_log("Removing %{public}@", log: log, type: .default, repository)
        }
    }

    func warning(message: String) {
        if #available(macOS 10.12, *) {
            let log = OSLog(subsystem: "me.lovelett.langserver-swift", category: "ToolWorkspaceDelegate")
            os_log("Warning %{public}@", log: log, type: .default, message)
        }
    }
}
