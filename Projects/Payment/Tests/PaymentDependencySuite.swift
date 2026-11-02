import Testing

@Suite(.serialized)
struct PaymentDependencySuite {
    // Nested so suites sharing Dependencies.shared and the store persistence never run in parallel.
}
