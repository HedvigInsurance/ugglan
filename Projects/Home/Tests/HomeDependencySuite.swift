import Testing

@Suite(.serialized)
struct HomeDependencySuite {
    // Nested so suites sharing the AppStateContainer stores and Dependencies.shared never run in parallel.
}
