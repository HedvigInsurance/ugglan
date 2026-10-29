import Testing

@Suite(.serialized)
struct MoveFlowDependencySuite {
    // Nested so suites sharing Dependencies.shared run serially: .serialized only orders its own children.
}
