import Testing

@Suite(.serialized)
struct ForeverDependencySuite {
    // Nested so suites sharing ForeverClient run serially: .serialized only orders its own children.
}
