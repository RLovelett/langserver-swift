import Foundation

/// This type represents the 
public struct Request {
    public let method: String
    public let params: Any?
    public let id: RequestID

    init?(from json: Any) {
        guard let obj = json as? [String : Any] else {
            return nil
        }

        guard let method = obj["method"] as? String else {
            return nil
        }

        if let id = obj["id"] {
            switch id {
            case let val as String:
                self.id = RequestID.String(val)
            case let val as NSNumber:
                self.id = RequestID.Number(val.intValue)
            default:
                return nil
            }
        } else {
            self.id = RequestID.Null
        }

        self.method = method
        self.params = obj["params"]
    }
}
