import Apollo
import Foundation

extension JSONObject {
    public var prettyPrinted: NSString? {
        if let data = try? JSONSerialization.data(withJSONObject: self, options: .prettyPrinted) {
            return NSString(data: data, encoding: String.Encoding.utf8.rawValue) ?? nil
        } else {
            return nil
        }
    }
}
