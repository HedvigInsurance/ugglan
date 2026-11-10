import Testing

@Suite(.serialized)
struct ChangeTierDependencySuite {
    // Nested because these suites share Dependencies.shared; .serialized only orders a suite's own children.
}
