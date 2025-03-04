import Environment
import Foundation

extension String {
    public var isDeepLink: Bool {
        let detector = try? NSDataDetector(types: NSTextCheckingResult.CheckingType.link.rawValue)
        if let match = detector?
            .firstMatch(in: self, options: [], range: NSRange(location: 0, length: utf16.count))
        {
            if let url = URL(string: self), Environment.current.isDeeplink(url) {
                return match.range.length == utf16.count
            }
            return false
        } else {
            return false
        }
    }
}
