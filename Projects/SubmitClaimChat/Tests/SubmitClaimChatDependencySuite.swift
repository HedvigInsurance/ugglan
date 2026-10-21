import Testing

@Suite(.serialized)
struct SubmitClaimChatDependencySuite {
    // Nested so the suites sharing Dependencies.shared and the key window never run in parallel:
    // .serialized only orders its own children.
}
