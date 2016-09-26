import Foundation

public struct Response {
    public let id: RequestID
    let result: Result

    public init(to id: RequestID, result: Result) {
        self.id = id
        self.result = result
    }

    var json: [String : Any] {
        var obj: [String : Any] = [
            "jsonrpc" : "2.0"
        ]

        switch id {
        case .Number(let val): obj["id"] = val
        case .String(let val): obj["id"] = val
        case .Null: obj["id"] = NSNull()
        }

        switch result {
        case .Success(let result):
            switch result {
            case .some(let r): obj["result"] = r
            case .none: obj["result"] = [:]
            }
        case .Error(let error):
            obj["error"] = [
                "code" : error.code,
                "message" : error.message
            ]
        }

        return obj
    }

    public enum Result {
        case Success([String : Any]?)
        case Error(ServerError)
    }
}
