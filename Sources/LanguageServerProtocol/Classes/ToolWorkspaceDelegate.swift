//
//  ToolWorkspaceDelegate.swift
//  langserver-swift
//
//  Created by Ryan Lovelett on 4/16/17.
//
//

import Basic
#if os(macOS) || os(iOS) || os(watchOS) || os(tvOS)
import os.log
#endif
import PackageGraph
import Workspace

class ToolWorkspaceDelegate: WorkspaceDelegate {
    func packageGraphWillLoad(currentGraph: PackageGraph, dependencies: AnySequence<ManagedDependency>, missingURLs: Set<String>) {
        #if os(macOS) || os(iOS) || os(watchOS) || os(tvOS)
            let log = OSLog(subsystem: "me.lovelett.langserver-swift", category: "ToolWorkspaceDelegate")
            os_log("The workspace is about to load the complete package graph.", log: log, type: .default)
        #endif
    }

    func fetchingWillBegin(repository: String) {
        #if os(macOS) || os(iOS) || os(watchOS) || os(tvOS)
            let log = OSLog(subsystem: "me.lovelett.langserver-swift", category: "ToolWorkspaceDelegate")
            os_log("The workspace has started fetching %{public}@", log: log, type: .default, repository)
        #endif
    }

    func fetchingDidFinish(repository: String, diagnostic: Diagnostic?) {
        #if os(macOS) || os(iOS) || os(watchOS) || os(tvOS)
            let log = OSLog(subsystem: "me.lovelett.langserver-swift", category: "ToolWorkspaceDelegate")
            os_log("The workspace has finished fetching %{public}@", log: log, type: .default, repository)
        #endif
    }

    func repositoryWillUpdate(_ repository: String) {
        #if os(macOS) || os(iOS) || os(watchOS) || os(tvOS)
            let log = OSLog(subsystem: "me.lovelett.langserver-swift", category: "ToolWorkspaceDelegate")
            os_log("The workspace has started updating %{public}@", log: log, type: .default, repository)
        #endif
    }

    func repositoryDidUpdate(_ repository: String) {
        #if os(macOS) || os(iOS) || os(watchOS) || os(tvOS)
            let log = OSLog(subsystem: "me.lovelett.langserver-swift", category: "ToolWorkspaceDelegate")
            os_log("The workspace has finished updating %{public}@", log: log, type: .default, repository)
        #endif
    }

    func cloning(repository: String) {
        #if os(macOS) || os(iOS) || os(watchOS) || os(tvOS)
            let log = OSLog(subsystem: "me.lovelett.langserver-swift", category: "ToolWorkspaceDelegate")
            os_log("The workspace has started cloning %{public}@", log: log, type: .default, repository)
        #endif
    }

    func checkingOut(repository: String, atReference: String, to path: AbsolutePath) {
        // FIXME: This is temporary output similar to old one, we will need to figure
        // out better reporting text.
        #if os(macOS) || os(iOS) || os(watchOS) || os(tvOS)
            let log = OSLog(subsystem: "me.lovelett.langserver-swift", category: "ToolWorkspaceDelegate")
            os_log("The workspace is checking out %{public}@", log: log, type: .default, repository)
        #endif
    }

    func removing(repository: String) {
        #if os(macOS) || os(iOS) || os(watchOS) || os(tvOS)
            let log = OSLog(subsystem: "me.lovelett.langserver-swift", category: "ToolWorkspaceDelegate")
            os_log("The workspace is removing %{public}@ because it is no longer needed.", log: log, type: .default, repository)
        #endif
    }

    func managedDependenciesDidUpdate(_ dependencies: AnySequence<ManagedDependency>) {
        #if os(macOS) || os(iOS) || os(watchOS) || os(tvOS)
            let log = OSLog(subsystem: "me.lovelett.langserver-swift", category: "ToolWorkspaceDelegate")
            os_log("Called when the managed dependencies are updated.", log: log, type: .default)
        #endif
    }

}
