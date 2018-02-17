import BaseProtocol
import Dispatch
import Foundation
import LanguageServerProtocol

private let header: [String : String] = [
    "Content-Type": "application/vscode-jsonrpc; charset=utf8"
]

let main = OperationQueue.main
let stdin = FileHandle.standardInput
var requests = RequestBuffer()

let global = DispatchQueue.global(qos: .background)
let channel = DispatchIO(type: .stream, fileDescriptor: stdin.fileDescriptor, queue: global) { _ in }

// The desire is to trigger the handler block as soon as there is any data in the channel.
channel.setLimit(lowWater: 1)

channel.read(offset: 0, length: Int.max, queue: .main) { (end, _, error) in
  let buffer = stdin.availableData

  guard !buffer.isEmpty else {
    return
  }

  requests.append(buffer)

  for requestBuffer in requests {
    do {
      let request = try Request(requestBuffer)
      let response = handle(request)
      /// If the request id is null then it is a notification and not a request
      switch request {
      case .request(_, _, _):
        let toSend = response.data(header)
        FileHandle.standardOutput.write(toSend)
      default: ()
      }
    } catch let error as PredefinedError {
      fatalError(error.description)
    } catch {
      fatalError("TODO: Better error handeling. \(error)")
    }
  }
}

// Launch the task
RunLoop.main.run()
//while RunLoop.main.run(mode: .defaultRunLoopMode, before: .distantFuture) {}
