import Testing

@Suite(.serialized)
struct ContractsDependencySuite {
    // Nested so suites sharing FetchContractsClient run serially: .serialized only orders its own children.
}
