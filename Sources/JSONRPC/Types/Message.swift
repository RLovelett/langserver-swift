import Foundation

private let pattern = Data(bytes: [0x0D, 0x0A, 0x0D, 0x0A])

public struct IncomingMessage {
    let header: [String : String]
    public let content: Request

    public init(_ data: Data) throws {
        let headerTerminator = data.range(of: pattern)

        if let headerRange = headerTerminator.map({ Range<Data.Index>(0..<$0.upperBound) }) {
            // TODO: Figure out what, if anything, we should use for parsing the header
            _ = data.subdata(in: headerRange)
            header = [ : ]
        } else {
            // Default to an empty header set
            header = [ : ]
        }

        let bodyRange = Range<Data.Index>((headerTerminator?.upperBound ?? 0)..<data.count)
        let body = data.subdata(in: bodyRange)

        guard let json = try? JSONSerialization.jsonObject(with: body, options: []) else {
            throw JSONRPC.PredefinedError.Parse
        }

        guard let request = Request(from: json) else {
            throw JSONRPC.PredefinedError.InvalidRequest
        }

        content = request
    }
}

public struct OutgoingMessage: CustomStringConvertible {
    let header: [String : String]
    let content: Response

    public init(header: [String : String], content: Response) {
        self.header = header
        self.content = content
    }

    public var description: String {
        return String(data: data, encoding: .utf8) ?? "Could not convert to UTF-8"
    }

    public var data: Data {
        var mutableHeader = header

        guard let jsonData = try? JSONSerialization.data(withJSONObject: content.json, options: .prettyPrinted) else {
            return pattern
        }

        if !jsonData.isEmpty {
            mutableHeader["Content-Length"] = String(jsonData.count)
        }

        var headerData = mutableHeader.map({ "\($0): \($1)" })
            .joined(separator: "\r\n")
            .appending("\r\n\r\n")
            .data(using: .utf8)

        headerData?.append(jsonData)

        return headerData ?? pattern
    }
}
