import Testing

@Suite(.serialized)
struct ChatDependencySuite {
    // Nested so suites sharing Dependencies.shared and the global log never run in parallel.
}
