import Foundation

extension String {
    public func toJSONDictionary() -> [String: Any]? {
        if let data = self.data(using: .utf8) {
            let json =
                try? JSONSerialization.jsonObject(with: data, options: .mutableContainers)
                as? [String: Any]
            return json
        }
        return nil
    }
}
