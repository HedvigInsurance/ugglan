extension Sequence where Element == String {
    /// Joins the elements of the given sequence into a single string, using the specified separator.
    public var displayName: String {
        joined(separator: " • ")
    }
}
