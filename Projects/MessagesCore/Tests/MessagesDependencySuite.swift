import Testing

@Suite(.serialized)
struct MessagesDependencySuite {
    // Nested because these suites share Dependencies.shared; .serialized only orders a suite's own children.
}
