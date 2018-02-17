import BaseProtocol
import Dispatch
import Foundation
import LanguageServerProtocol

extension Data {
  init(copy: DispatchData) {
    self = copy.withUnsafeBytes { (ptr: UnsafePointer<CChar>) -> Data in
      return Data(bytes: ptr, count: copy.count)
    }
  }
}

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

channel.read(offset: 0, length: Int.max, queue: .main) { (end, possibleData, error) in
  guard !end else {
    exit(0)
  }

  guard let data = possibleData, !data.isEmpty else {
    return
  }

  FileHandle.standardError.write("Here".data(using: .utf8)!)

  let buffer = Data(copy: data)
  requests.append(buffer)

  for requestBuffer in requests {
    do {
      let request = try Request(requestBuffer)
      // dump(request)
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
