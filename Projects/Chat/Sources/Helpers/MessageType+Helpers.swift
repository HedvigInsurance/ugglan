import Foundation

extension String {
    public var isGIFURL: Bool {
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
    public var isCrossSell: Bool {
        let detector = try? NSDataDetector(types: NSTextCheckingResult.CheckingType.link.rawValue)
        if let match = detector?
            .firstMatch(in: self, options: [], range: NSRange(location: 0, length: utf16.count))
        {
            return match.range.length == utf16.count && contains("CROSS_SELL")
        } else {
            return false
        }
    }
}

extension String {
    public var isUrl: Bool {
        let detector = try? NSDataDetector(types: NSTextCheckingResult.CheckingType.link.rawValue)
        if let match = detector?
            .firstMatch(in: self, options: [], range: NSRange(location: 0, length: utf16.count))
        {
            return match.range.length == utf16.count
        } else {
            return false
        }
    }
}
