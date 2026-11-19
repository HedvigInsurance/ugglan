import Testing

@Suite(.serialized)
struct TerminateContractsDependencySuite {
    // Nested so suites sharing TerminateContractsClient run serially: .serialized only orders its own children.
}
