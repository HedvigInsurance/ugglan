import Foundation

extension String {
    var tokens: [Token] {
        var cursor: Int = 0
        var intermediate: [Token] = []

        while cursor < count {
            let currentRange = NSRange(location: cursor, length: count - cursor)

            let voidMatches = TokenCheckers.void.matches(in: self, options: [], range: currentRange)

            if let range = voidMatches.first?.range {
                cursor = cursor + range.length
            } else {
                if let tokenChecker = TokenCheckers.matchers.first(where: { key, _ in
                    !key.matches(in: self, options: [], range: currentRange).isEmpty
                }) {
                    let matches = tokenChecker.key.matches(
                        in: self,
                        options: [],
                        range: currentRange
                    )

                    if let match = matches.first {
                        intermediate.append(tokenChecker.value(match.range, self))
                        cursor += match.range.length
                    }
                } else {
                    cursor += currentRange.length
                }
            }
        }

        return intermediate
    }
}
