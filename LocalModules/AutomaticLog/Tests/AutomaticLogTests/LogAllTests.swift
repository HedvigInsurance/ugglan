import AutomaticLog
import Testing

nonisolated(unsafe) private var capturedLogs: [String] = []

@LogAll(masked: ["token"])
private struct TypeLevelService {
    func plain(id: String) -> String {
        "plain-\(id)"
    }

    func exchange(token: String, id: String) -> Int {
        token.count + id.count
    }

    @Log(.error)
    func quiet(id: String) throws -> String {
        "quiet-\(id)"
    }

    @Log(.error)
    func failing(token: String) throws {
        throw TypeLevelError.rejected
    }

    @Log(masked: ["id"])
    func both(token: String, id: String) -> Int {
        token.count + id.count
    }

    var computed: Int { 1 }
}

private enum TypeLevelError: Error {
    case rejected
}

extension LoginClosureSuite {
    final class LogAllTests {
        init() {
            capturedLogs = []
            loginClosure = { capturedLogs.append($0) }
        }

        // Restores the process-wide closure after every test, even one that throws.
        deinit {
            loginClosure = { print($0) }
        }

        @Test
        func everyFunctionIsLogged() throws {
            _ = TypeLevelService().plain(id: "1")

            #expect(capturedLogs.count == 1)
            let log = try #require(capturedLogs.first)
            #expect(log.contains("TypeLevelService plain"), Comment(rawValue: log))
            #expect(log.contains("\"id\": \"1\""), Comment(rawValue: log))
        }

        @Test
        func maskedNamesApplyWhereTheParameterExists() throws {
            _ = TypeLevelService().exchange(token: "secret", id: "7")

            #expect(capturedLogs.count == 1)
            let log = try #require(capturedLogs.first)
            #expect(log.contains("secret") == false, Comment(rawValue: log))
            #expect(log.contains("\"token\": \"******\""), Comment(rawValue: log))
            #expect(log.contains("\"id\": \"7\""), Comment(rawValue: log))
        }

        @Test
        func functionLevelLogWins() throws {
            _ = try TypeLevelService().quiet(id: "1")

            #expect(capturedLogs.count == 0, "\(capturedLogs)")
        }

        @Test
        func functionLevelLogKeepsTheTypeLevelMask() throws {
            #expect(throws: (any Error).self) { try TypeLevelService().failing(token: "secret") }

            #expect(capturedLogs.count == 1)
            let log = try #require(capturedLogs.first)
            #expect(log.contains("secret") == false, Comment(rawValue: log))
            #expect(log.contains("\"token\": \"******\""), Comment(rawValue: log))
        }

        @Test
        func ownAndTypeLevelMasksAreUnioned() throws {
            _ = TypeLevelService().both(token: "secret", id: "42")

            #expect(capturedLogs.count == 1)
            let log = try #require(capturedLogs.first)
            #expect(log.contains("secret") == false, Comment(rawValue: log))
            #expect(log.contains("42") == false, Comment(rawValue: log))
            #expect(log.contains("\"token\": \"******\""), Comment(rawValue: log))
            #expect(log.contains("\"id\": \"**\""), Comment(rawValue: log))
        }
    }
}
