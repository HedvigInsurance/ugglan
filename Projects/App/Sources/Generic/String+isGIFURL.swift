import Foundation
import hGraphQL

extension String {
    var isGIFURL: Bool {
        let detector = try? NSDataDetector(types: NSTextCheckingResult.CheckingType.link.rawValue)
        if let match = detector?
            .firstMatch(in: self, options: [], range: NSRange(location: 0, length: utf16.count))
        {
            return match.range.length == utf16.count && contains(".gif")
        } else {
            return false
        }
    }
}

extension String {
    var isDeepLink: Bool {
        let detector = try? NSDataDetector(types: NSTextCheckingResult.CheckingType.link.rawValue)
        if let match = detector?
            .firstMatch(in: self, options: [], range: NSRange(location: 0, length: utf16.count))
        {

            return match.range.length == utf16.count && contains(Environment.current.deepLinkUrl)
        } else {
            return false
        }
    }
}
