#if os(macOS) || os(iOS) || os(tvOS) || os(watchOS)
    import Darwin
#elseif os(Linux)
    import Glibc
#endif

import Foundation
import Dispatch
import Socket

class EchoServer {

    static let QUIT: String = "QUIT"
    static let SHUTDOWN: String = "SHUTDOWN"
    static let BUFFER_SIZE = 4096

    let port: Int

    var listenSocket: Socket? = nil

    var continueRunning = true
    var connectedSockets = [Int32: Socket]()
    let socketLockQueue: DispatchQueue? = DispatchQueue(label: "com.ibm.serverSwift.socketLockQueue")

    init(port: Int) {

        self.port = port
    }

    deinit {

        // Close all open sockets...
        for socket in connectedSockets.values {

            socket.close()
        }

        self.listenSocket?.close()
    }

    func run() {

        let queue: DispatchQueue? = DispatchQueue.global(qos: .userInteractive)
        guard let pQueue = queue else {

            fatalError("Unable to access global interactive QOS queue")
        }

        pQueue.async { [unowned self] in

            do {

                // Create an IPV6 socket...
                try self.listenSocket = Socket.create(family: .inet6)

                guard let socket = self.listenSocket else {

                    print("Unable to unwrap socket...")
                    return
                }

                try socket.listen(on: self.port, maxBacklogSize: 10)

                print("Listening on port: \(socket.listeningPort)")

                repeat {

                    let newSocket = try socket.acceptClientConnection()

                    print("Accepted connection from: \(newSocket.remoteHostname) on port \(newSocket.remotePort)")
                    print("Socket Signature: \(newSocket.signature?.description)")

                    self.addNewConnection(socket: newSocket)

                } while self.continueRunning

            } catch let error {

                guard let socketError = error as? Socket.Error else {

                    print("Unexpected error...")
                    return
                }

                if self.continueRunning {

                    print("Error reported:\n \(socketError.description)")

                }
            }
        }

        dispatchMain()

    }

    func addNewConnection(socket: Socket) {

        // Make sure we've got a lock queue...
        guard let lockq = self.socketLockQueue else {

            fatalError("Unable to access socket lock queue")
        }

        // Add the new socket to the list of connected sockets...
        lockq.sync { [unowned self, socket] in

            self.connectedSockets[socket.socketfd] = socket
        }

        // Get the global concurrent queue...
        let queue: DispatchQueue? = DispatchQueue.global(qos: .default)
        guard let pQueue = queue else {

            fatalError("Unable to access global default QOS queue")
        }

        // Create the run loop work item and dispatch to the default priority global queue...
        pQueue.async { [unowned self, socket] in

            var shouldKeepRunning = true

            guard let readData = NSMutableData(capacity:EchoServer.BUFFER_SIZE) else {

                fatalError("Unable to create data buffer...")
            }

            do {

                // Write the welcome string...
                try socket.write(from: "Hello, type 'QUIT' to end session\nor 'SHUTDOWN' to stop server.\n")

                repeat {

                    let bytesRead = try socket.read(into: readData)

                    if bytesRead > 0 {


                        guard let response = NSString(bytes: readData.bytes, length: readData.length, encoding: String.Encoding.utf8.rawValue) else {

                            print("Error decoding response...")
                            readData.length = 0
                            break
                        }
                        if response.hasPrefix(EchoServer.SHUTDOWN) {

                            print("Shutdown requested by connection at \(socket.remoteHostname):\(socket.remotePort)")

                            // Shut things down...
                            self.shutdownServer()

                            return
                        }
                        print("Server received from connection at \(socket.remoteHostname):\(socket.remotePort): \(response) ")
                        let reply = "Server response: \n\(response)\n"
                        try socket.write(from: reply)

                        if (response.uppercased.hasPrefix(EchoServer.QUIT) || response.uppercased.hasPrefix(EchoServer.SHUTDOWN)) &&
                            (!response.hasPrefix(EchoServer.QUIT) && !response.hasPrefix(EchoServer.SHUTDOWN)) {

                            try socket.write(from: "If you want to QUIT or SHUTDOWN, please type the name in all caps. 😃\n")
                        }

                        if response.hasPrefix(EchoServer.QUIT) || response.hasSuffix(EchoServer.QUIT) {

                            shouldKeepRunning = false
                        }
                    }

                    if bytesRead == 0 {

                        shouldKeepRunning = false
                        break
                    }

                    readData.length = 0

                } while shouldKeepRunning

                print("Socket: \(socket.remoteHostname):\(socket.remotePort) closed...")
                socket.close()

                lockq.sync { [unowned self, socket] in

                    self.connectedSockets[socket.socketfd] = nil
                }

            } catch let error {
                
                guard let socketError = error as? Socket.Error else {
                    
                    print("Unexpected error by connection at \(socket.remoteHostname):\(socket.remotePort)...")
                    return
                }
                
                if (self.continueRunning) {
                    
                    print("Error reported by connection at \(socket.remoteHostname):\(socket.remotePort):\n \(socketError.description)")
                    
                }
                
            }
        }
    }
    
    func shutdownServer() {
        
        print("\nShutdown in progress...")
        self.continueRunning = false
        
        // Close all open sockets...
        for socket in connectedSockets.values {
            
            socket.close()
        }
        
        self.listenSocket?.close()
        
        DispatchQueue.main.sync {
            exit(0)
        }
    }
}

class IPCClient {

    let port: Int
    var listenSocket: Socket? = nil
    let socketLockQueue: DispatchQueue? = DispatchQueue(label: "com.ibm.serverSwift.socketLockQueue")
    var continueRunning = true

    init(port: Int) {
        self.port = port
    }

    func run() {
        let queue: DispatchQueue? = DispatchQueue.global(qos: .userInteractive)
        guard let pQueue = queue else {
            fatalError("Unable to access global interactive QOS queue")
        }

        pQueue.async { [unowned self] in

            do {

                // Create an IPV6 socket...
                self.listenSocket = try Socket.create(family: .inet6)

                guard let socket = self.listenSocket else {
                    fatalError("IDK.")
                }

                // Seems weird that it's an Int32
                try socket.connect(to: "::", port: Int32(self.port))
                guard socket.isConnected else {
//                    DispatchQueue.main.sync {
                        exit(0)
//                    }
                }
                print("Connected to \(socket.remoteHostname):\(socket.remotePort)")

                guard let readData = NSMutableData(capacity: EchoServer.BUFFER_SIZE) else {
                    fatalError("Unable to create data buffer...")
                }

                repeat {

                    let bytesRead = try socket.read(into: readData)

                    guard bytesRead > 0 else { break }

                    guard let response = NSString(bytes: readData.bytes, length: readData.length, encoding: String.Encoding.utf8.rawValue) else {

                        print("Error decoding response...")
                        readData.length = 0
                        break
                    }

                    print("Client received from server at \(socket.remoteHostname):\(socket.remotePort): \(response)")
                    try socket.write(from: "👋")

                    readData.length = 0

                } while socket.isConnected
                
                print("Socket: \(socket.remoteHostname):\(socket.remotePort) closed...")
                socket.close()

                DispatchQueue.main.sync {
                    exit(0)
                }

            } catch let error {

                guard let socketError = error as? Socket.Error else {

                    print("Unexpected error...")
                    return
                }
            }
        }
        
        dispatchMain()
    }
}

let port = 1337
//let server = EchoServer(port: port)
//print("Swift Echo Server Sample")
//print("Connect with ETEchoClient iOS app or use Terminal via 'telnet 127.0.0.1 \(port)'")
//
//server.run()

let client = IPCClient(port: port)
client.run()
