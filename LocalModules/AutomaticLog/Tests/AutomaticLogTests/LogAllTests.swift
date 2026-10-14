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

    func testFunctionLevelLogKeepsTheTypeLevelMask() {
        XCTAssertThrowsError(try TypeLevelService().failing(token: "secret"))

        XCTAssertEqual(capturedLogs.count, 1)
        XCTAssertFalse(capturedLogs[0].contains("secret"), capturedLogs[0])
        XCTAssertTrue(capturedLogs[0].contains("\"token\": \"******\""), capturedLogs[0])
    }

    func testOwnAndTypeLevelMasksAreUnioned() {
        _ = TypeLevelService().both(token: "secret", id: "42")

        XCTAssertEqual(capturedLogs.count, 1)
        XCTAssertFalse(capturedLogs[0].contains("secret"), capturedLogs[0])
        XCTAssertFalse(capturedLogs[0].contains("42"), capturedLogs[0])
        XCTAssertTrue(capturedLogs[0].contains("\"token\": \"******\""), capturedLogs[0])
        XCTAssertTrue(capturedLogs[0].contains("\"id\": \"**\""), capturedLogs[0])
    }
}
