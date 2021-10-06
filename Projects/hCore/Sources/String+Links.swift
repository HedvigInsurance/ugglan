import Foundation

extension String {
    /// returns all http/https links in the string
    public var links: [NSTextCheckingResult] {
        let detector = try? NSDataDetector(types: NSTextCheckingResult.CheckingType.link.rawValue)

        guard let detect = detector else { return [] }

        let matches = detect.matches(
            in: self,
            options: .reportCompletion,
            range: NSRange(location: 0, length: count)
        )

        return matches
    }
}
