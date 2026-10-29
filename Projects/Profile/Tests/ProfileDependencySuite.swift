import Testing

@Suite(.serialized)
struct ProfileDependencySuite {
    // Nested because these suites share Dependencies.shared and app-state persistence; .serialized can't span suites.
}
