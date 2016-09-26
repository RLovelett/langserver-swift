import Dispatch
import Foundation
import Socket

public class Server {

    static let BUFFER_SIZE = 4096

    let port: Int

    let listenSocket: Socket

    fileprivate var activeConnections: [Int32 : Connection] = [:]

    let lockq = DispatchQueue(label: "me.lovelett.jsonrpc.queue.lock")

    let queue = DispatchQueue.global(qos: .userInteractive)

    let closure: (Request) -> (Response)

    public init(listen port: Int, closure: @escaping (Request) -> (Response)) throws {
        self.port = port
        self.listenSocket = try Socket.create(family: .inet6, type: .stream, proto: .tcp)
        self.closure = closure
    }

    deinit {
        self.activeConnections.forEach({ $0.value.socket.close() })
        self.listenSocket.close()
    }

    public func start() {
        queue.async { [unowned self] in
            do {
                try self.listenSocket.listen(on: self.port)

                repeat {
                    let newSocket = try self.listenSocket.acceptClientConnection()
                    self.add(Connection(from: newSocket))
                } while self.listenSocket.isActive
            } catch {
                fatalError("TODO: Better error handeling. \(error)")
            }
        }
    }

    public func stop() {
        self.listenSocket.close()
    }

    private func add(_ connection: Connection) {
        // Add the new socket to the list of connected sockets...
        lockq.sync { [unowned self, connection] in
            self.activeConnections[connection.socket.socketfd] = connection
        }

        queue.async { [unowned self, connection] in
            connection.run(self.closure, beforeClose: self.remove)
        }
    }

    private func remove(_ connection: Connection) {
        lockq.sync { [unowned self, connection] in
            self.activeConnections[connection.socket.socketfd] = nil
        }
    }

}

private let header: [String : String] = [
    "Content-Type": "application/vscode-jsonrpc; charset=utf8"
]

fileprivate class Connection {

    let socket: Socket

    init(from socket: Socket) {
        self.socket = socket
    }

    deinit {
        self.socket.close()
    }

    func run(_ closure: @escaping (Request) -> (Response), beforeClose: @escaping (Connection) -> Void) {
        do {
            repeat {
                var buffer = Data(capacity: Server.BUFFER_SIZE)
                let bytesRead = try self.socket.read(into: &buffer)

                guard bytesRead > 0 else {
                    continue
                }

                do {
                    let message = try IncomingMessage(buffer)
                    let response = closure(message.content)
                    let toSend = OutgoingMessage(header: header, content: response)
                    print(toSend)
                    _ = try self.socket.write(from: toSend.data)
                } catch let error as PredefinedError {
                    let response = Response(to: .Null, result: .Error(error))
                    let toSend = OutgoingMessage(header: header, content: response)
                    print(toSend)
                    _ = try self.socket.write(from: toSend.data)
                }

            } while !self.socket.remoteConnectionClosed

            beforeClose(self)
        } catch {
            fatalError("TODO: Better error handeling. \(error)")
        }
    }

}
