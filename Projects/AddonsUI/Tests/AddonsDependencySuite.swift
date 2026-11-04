import Testing

@Suite(.serialized)
struct AddonsDependencySuite {
    // Nested because these suites share Dependencies.shared; .serialized only orders a suite's own children.
}
