import Testing

@Suite(.serialized)
struct LoginClosureSuite {
    // Nested so suites sharing AutomaticLog.loginClosure run serially: .serialized only orders its own children.
}
