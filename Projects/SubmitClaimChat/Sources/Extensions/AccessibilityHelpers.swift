import Foundation
import hCore

/// Helpers for building accessibility strings in claim chat steps
extension String {
    /// Builds an accessibility string for submitted values
    /// - Parameters:
    ///   - count: Number of submitted values
    ///   - values: Array of value strings to announce
    /// - Returns: Formatted accessibility string
    static func accessibilitySubmittedValues(count: Int, values: [String]) -> String {
        guard !values.isEmpty else { return "" }
        return L10n.a11YSubmittedValues(count) + ": " + values.joined(separator: ", ")
    }

    /// Builds an accessibility string for a single submitted value
    /// - Parameter value: The value string to announce
    /// - Returns: Formatted accessibility string
    static func accessibilitySubmittedValue(_ value: String) -> String {
        guard !value.isEmpty else { return "" }
        return L10n.a11YSubmittedValues(1) + ": " + value
    }
}
