import Testing

@Suite(.serialized)
struct CrossSellDependencySuite {
    // Nested because these suites share Dependencies.shared; .serialized only orders a suite's own children.
}
