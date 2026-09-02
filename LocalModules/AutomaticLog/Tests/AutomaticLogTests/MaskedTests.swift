import AutomaticLog
import Combine
import XCTest

@Loggable
private struct Member: Codable, Equatable, Hashable, Sendable {
    let name: String
    @Masked let email: String
    @Masked let phone: String?
}

/// Field names are matched exactly, so an unconventionally cased property still works.
@Loggable
private struct Stakeholder {
    let fullName: String
    @Masked let SSN: String?
}

/// The case `@Masked` exists for: a `@Published` property, which no property wrapper
/// could have been applied to.
@Loggable
private final class LoginState: ObservableObject {
    @Published var isLoading = false
    @Published @Masked var code = "1234"
}

/// An enum case's associated value cannot carry an attribute, so the type masks itself.
private enum Payload: MaskedValue {
    case text(text: String, id: String)
    case empty

    var maskedDescription: String {
        switch self {
        case let .text(text, id):
            return "text(text: \(maskedLogDescription(text)), id: \(logDescription(id)))"
        case .empty:
            return "empty"
        }
    }
}

private struct Envelope {
    let sentAt: String
    let payload: Payload
}

/// Captures what `@Log` emits. A global because `loginClosure` is `@Sendable`.
nonisolated(unsafe) private var capturedLogs: [String] = []

private struct Credentials {
    @Log(masked: ["refreshToken"])
    func exchange(refreshToken: String, id: String) -> String {
        "exchanged \(refreshToken.count) for \(id)"
    }

    @Log(.error, masked: ["token"])
    func register(for token: String) async throws {
        _ = token
    }

    @Log
    func member() throws -> Member {
        Member(name: "Alice", email: "alice@example.com", phone: nil)
    }
}

final class MaskedFieldTests: XCTestCase {
    func testMaskedStoredPropertyKeepsItsName() {
        let described = logDescription(Member(name: "Alice", email: "alice@example.com", phone: "070"))

        XCTAssertTrue(described.contains("name: Alice"))
        XCTAssertTrue(described.contains("email: *****************"))
        XCTAssertTrue(described.contains("phone: ***"))
        XCTAssertFalse(described.contains("alice@example.com"))
    }

    func testMaskedOptionalStaysNil() {
        XCTAssertTrue(logDescription(Member(name: "A", email: "a@b.c", phone: nil)).contains("phone: nil"))
    }

    func testFieldNamesAreMatchedExactly() {
        let described = logDescription(Stakeholder(fullName: "Alice A", SSN: "199001011234"))

        XCTAssertTrue(described.contains("fullName: Alice A"))
        XCTAssertFalse(described.contains("199001011234"))
    }

    func testPublishedPropertyIsMasked() {
        let described = logDescription(LoginState())

        XCTAssertFalse(described.contains("1234"))
        XCTAssertTrue(described.contains("code: "))
    }

    func testMaskedFieldsStayMaskedWhenNested() {
        let described = logDescription([Member(name: "A", email: "a@b.c", phone: nil)])

        XCTAssertFalse(described.contains("a@b.c"))
    }

    func testNonMaskedValuesAreUnchanged() {
        XCTAssertEqual(logDescription("plain"), "plain")
        XCTAssertEqual(logDescription(Optional<String>.none as Any), "nil")
    }

    func testLoggableDoesNotChangeTheCodableRepresentation() throws {
        let member = Member(name: "Alice", email: "alice@example.com", phone: "070")
        let json = String(data: try JSONEncoder().encode(member), encoding: .utf8)

        XCTAssertEqual(json?.contains("\"email\":\"alice@example.com\""), true)
        XCTAssertFalse(json?.contains("_email") ?? true)
    }
}

final class MaskedValueConformanceTests: XCTestCase {
    func testHandWrittenConformanceMasksOnlyThePayload() {
        let described = logDescription(Envelope(sentAt: "today", payload: .text(text: "hello there", id: "7")))

        XCTAssertTrue(described.contains("sentAt: today"))
        XCTAssertTrue(described.contains("payload: text(text: ***********, id: 7)"))
        XCTAssertFalse(described.contains("hello there"))
    }

    func testHandWrittenConformanceIsHonouredThroughCollections() {
        let described = logDescription([Envelope(sentAt: "today", payload: .text(text: "secret", id: "7"))])

        XCTAssertFalse(described.contains("secret"))
        XCTAssertTrue(described.contains("******"))
    }
}

final class MaskedParameterTests: XCTestCase {
    override func setUp() {
        super.setUp()
        capturedLogs = []
        loginClosure = { message in capturedLogs.append(message) }
    }

    override func tearDown() {
        loginClosure = { print($0) }
        super.tearDown()
    }

    func testListedParameterIsMaskedAndOthersAreNot() {
        let result = Credentials().exchange(refreshToken: "secret-token", id: "42")

        XCTAssertEqual(result, "exchanged 12 for 42")
        let log = capturedLogs.first
        XCTAssertFalse(log?.contains("secret-token") ?? true)
        XCTAssertEqual(log?.contains("************"), true)
        XCTAssertEqual(log?.contains("\"id\": \"42\""), true)
    }

    func testExternallyLabelledParameterIsMasked() async throws {
        try await Credentials().register(for: "device-token")

        let log = try XCTUnwrap(capturedLogs.first)
        XCTAssertFalse(log.contains("device-token"))
        XCTAssertTrue(log.contains("\"token\": \"************\""))
    }

    func testResultPropertiesAreMasked() throws {
        _ = try Credentials().member()

        let log = try XCTUnwrap(capturedLogs.first)
        XCTAssertFalse(log.contains("alice@example.com"))
        XCTAssertTrue(log.contains("name: Alice"))
    }
}
