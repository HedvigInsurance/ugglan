import Testing

@Suite(.serialized)
struct AppDependencySuite {
    // Nested so suites sharing Dependencies.shared and the app locale never run in parallel.
}
