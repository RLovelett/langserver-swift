import Dispatch
import Foundation
import JSONRPC
import XCGLogger

// Create a logger object with no destinations
let log = XCGLogger(identifier: "advancedLogger", includeDefaultDestinations: false)

// Create a destination for the system console log (via NSLog)
let systemDestination = AppleSystemLogDestination(identifier: "advancedLogger.systemDestination")

// Optionally set some configuration options
systemDestination.outputLevel = .verbose
systemDestination.showLogIdentifier = false
systemDestination.showFunctionName = true
systemDestination.showThreadName = true
systemDestination.showLevel = true
systemDestination.showFileName = true
systemDestination.showLineNumber = true
systemDestination.showDate = true

// Add the destination to the logger
log.add(destination: systemDestination)

// Add basic app info, version info etc, to the start of the logs
log.logAppDetails()

private let header: [String : String] = [
    "Content-Type": "application/vscode-jsonrpc; charset=utf8"
]

let main = OperationQueue.main
let stdin = FileHandle.standardInput
stdin.waitForDataInBackgroundAndNotify()

// When new data is available
var dataAvailable : NSObjectProtocol!
dataAvailable = NotificationCenter.default.addObserver(forName: .NSFileHandleDataAvailable, object: stdin, queue: main) { (notification) -> Void in
    let buffer = stdin.availableData

    guard !buffer.isEmpty else {
        return stdin.waitForDataInBackgroundAndNotify()
    }

    let str = String(data: buffer, encoding: .utf8) ?? "Expected UTF-8 encoding."
    log.verbose(str)

    do {
        let request = try Request(buffer)
        let response = handle(request)
        /// If the request id is null then it is a notification and not a request
        if case Request.Identifier.null = request.id {
            log.debug("The request was a notification and not a request.")
        } else {
            let toSend = response.data(header)
            log.debug(toSend)
            FileHandle.standardOutput.write(toSend)
        }
    } catch let error as PredefinedError {
        let response = Response(is: error)
        let toSend = response.data(header)
        log.debug(toSend)
        FileHandle.standardOutput.write(toSend)
    } catch {
        fatalError("TODO: Better error handeling. \(error)")
    }

    return stdin.waitForDataInBackgroundAndNotify()
}

// Launch the task
RunLoop.main.run()
//while RunLoop.main.run(mode: .defaultRunLoopMode, before: .distantFuture) {}
