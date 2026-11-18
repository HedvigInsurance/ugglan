import Testing

@Suite(.serialized)
struct ChangeMileageDependencySuite {
    // Nested because these suites share Dependencies.shared; .serialized only orders a suite's own children.
}
