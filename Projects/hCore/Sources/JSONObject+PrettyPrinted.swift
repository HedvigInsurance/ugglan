import Foundation
import Apollo

extension JSONObject {
    public var prettyPrinted: String? {
        if let data = try? JSONSerialization.data(withJSONObject: self, options: .prettyPrinted) {
            return String(data: data, encoding: .utf8 )
        } else {
            return nil
        }
    }
}
