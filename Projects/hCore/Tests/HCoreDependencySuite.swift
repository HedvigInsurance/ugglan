import Testing

@Suite(.serialized)
struct HCoreDependencySuite {
    // Nested so suites sharing currentLocale run serially: .serialized only orders its own children.
}
