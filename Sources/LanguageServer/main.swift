import BaseProtocol
import Dispatch
import Foundation
import LanguageServerProtocol

private let header: [String : String] = [
    "Content-Type": "application/vscode-jsonrpc; charset=utf8"
]

let readQueue = DispatchQueue(label: "me.lovelett.language-server.dispatchio", qos: .utility, attributes: [], autoreleaseFrequency: .workItem, target: nil)
var requests = RequestBuffer()

let channel = DispatchIO(type: .stream, fileDescriptor: FileHandle.standardInput.fileDescriptor, queue: readQueue) { (error) in
    // If the error parameter contains a non zero value, control was relinquished because there was an error creating
    // the channel; otherwise, this value should be 0.
    // See: https://developer.apple.com/documentation/dispatch/dispatchio/1388976-init
    exit(error)
}

// The desire is to trigger the handler block as soon as there is any data in the channel.
channel.setLimit(lowWater: 1)

channel.read(offset: 0, length: Int.max, queue: readQueue) { (done, dispatchData, error) in
    switch (done, dispatchData, error) {
    case (true, _, 1...):
        // If an unrecoverable error occurs on the channel’s file descriptor, the `done` parameter is set to `true` and
        // an appropriate error value is reported in the handler’s error parameter.
        fatalError("An unrecoverable error occurred on stdin. \(error)")
    case (true, let data?, 0) where data.isEmpty:
        // If the handler is submitted with the `done` parameter set to `true`, an empty `data` object, and an `error`
        // code of `0`, it means that the channel reached the end of the file.
        channel.close()
    case (_, let data?, 0) where !data.isEmpty:
        requests.append(data)
        for requestBuffer in requests {
            do {
                let request = try Request(requestBuffer)
                let response = handle(request)
                /// If the request id is null then it is a notification and not a request
                switch request {
                case .request(_, _, _):
                    let toSend = response.data(header)
                    // TODO: Writing to stdout should really be done on the main queue
                    FileHandle.standardOutput.write(toSend)
                default: ()
                }
            } catch let error as PredefinedError {
                fatalError(error.description)
            } catch {
                fatalError("TODO: Better error handeling. \(error)")
            }
        }
        if (done) {
            // If the `done` parameter is set to `true`, it means the read operation is complete and the handler will
            // not be submitted again.
            channel.close()
        }
    default:
        fatalError("This is an unexpected case.")
    }
}

// Launch the task
RunLoop.main.run()
