import AutomaticLog
import XCTest

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

    var computed: Int { 1 }
}

final class LogAllTests: XCTestCase {
    override func setUp() {
        super.setUp()
        capturedLogs = []
        loginClosure = { capturedLogs.append($0) }
    }

    override func tearDown() {
        loginClosure = { print($0) }
        super.tearDown()
    }

    func testEveryFunctionIsLogged() {
        _ = TypeLevelService().plain(id: "1")

        XCTAssertEqual(capturedLogs.count, 1)
        XCTAssertTrue(capturedLogs[0].contains("TypeLevelService plain"), capturedLogs[0])
        XCTAssertTrue(capturedLogs[0].contains("\"id\": \"1\""), capturedLogs[0])
    }

    func testMaskedNamesApplyWhereTheParameterExists() {
        _ = TypeLevelService().exchange(token: "secret", id: "7")

        XCTAssertEqual(capturedLogs.count, 1)
        XCTAssertFalse(capturedLogs[0].contains("secret"), capturedLogs[0])
        XCTAssertTrue(capturedLogs[0].contains("\"token\": \"******\""), capturedLogs[0])
        XCTAssertTrue(capturedLogs[0].contains("\"id\": \"7\""), capturedLogs[0])
    }

    func testFunctionLevelLogWins() throws {
        _ = try TypeLevelService().quiet(id: "1")

        XCTAssertEqual(capturedLogs.count, 0, "\(capturedLogs)")
    }
}
