import AutomaticLog
import Foundation
import Testing

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

/// Stands in for any property wrapper: the wrapped value is stored under a leading underscore.
@propertyWrapper
private struct Stored<Value> {
    var wrappedValue: Value
}

/// The case `@Masked` exists for: a property that already carries another property wrapper.
@Loggable
private final class LoginState {
    var isLoading = false
    @Stored @Masked var code = "1234"
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

    @Log(masked: ["token"])
    func register(for token: String) async throws {
        _ = token
    }

    @Log
    func member() throws -> Member {
        Member(name: "Alice", email: "alice@example.com", phone: nil)
    }
}

final class MaskedFieldTests {
    @Test
    func maskedStoredPropertyKeepsItsName() {
        let described = logDescription(Member(name: "Alice", email: "alice@example.com", phone: "070"))

        #expect(described.contains("name: Alice"))
        #expect(described.contains("email: *****************"))
        #expect(described.contains("phone: ***"))
        #expect(described.contains("alice@example.com") == false)
    }

    @Test
    func maskedOptionalStaysNil() {
        #expect(logDescription(Member(name: "A", email: "a@b.c", phone: nil)).contains("phone: nil"))
    }

    @Test
    func fieldNamesAreMatchedExactly() {
        let described = logDescription(Stakeholder(fullName: "Alice A", SSN: "199001011234"))

        #expect(described.contains("fullName: Alice A"))
        #expect(described.contains("199001011234") == false)
    }

    @Test
    func publishedPropertyIsMasked() {
        let described = logDescription(LoginState())

        #expect(described.contains("1234") == false)
        #expect(described.contains("code: "))
    }

    @Test
    func maskedFieldsStayMaskedWhenNested() {
        let described = logDescription([Member(name: "A", email: "a@b.c", phone: nil)])

        #expect(described.contains("a@b.c") == false)
    }

    @Test
    func nonMaskedValuesAreUnchanged() {
        #expect(logDescription("plain") == "plain")
        #expect(logDescription(Optional<String>.none as Any) == "nil")
    }

    @Test
    func loggableDoesNotChangeTheCodableRepresentation() throws {
        let member = Member(name: "Alice", email: "alice@example.com", phone: "070")
        let json = String(data: try JSONEncoder().encode(member), encoding: .utf8)

        #expect(json?.contains("\"email\":\"alice@example.com\"") == true)
        #expect(json?.contains("_email") == false)
    }
}

final class MaskedValueConformanceTests {
    @Test
    func handWrittenConformanceMasksOnlyThePayload() {
        let described = logDescription(Envelope(sentAt: "today", payload: .text(text: "hello there", id: "7")))

        #expect(described.contains("sentAt: today"))
        #expect(described.contains("payload: text(text: ***********, id: 7)"))
        #expect(described.contains("hello there") == false)
    }

    @Test
    func handWrittenConformanceIsHonouredThroughCollections() {
        let described = logDescription([Envelope(sentAt: "today", payload: .text(text: "secret", id: "7"))])

        #expect(described.contains("secret") == false)
        #expect(described.contains("******"))
    }
}

extension LoginClosureSuite {
    final class MaskedParameterTests {
        init() {
            capturedLogs = []
            loginClosure = { message in capturedLogs.append(message) }
        }

        // Restores the process-wide closure after every test, even one that throws.
        deinit {
            loginClosure = { print($0) }
        }

        @Test
        func listedParameterIsMaskedAndOthersAreNot() {
            let result = Credentials().exchange(refreshToken: "secret-token", id: "42")

            #expect(result == "exchanged 12 for 42")
            let log = capturedLogs.first
            #expect(log?.contains("secret-token") == false)
            #expect(log?.contains("************") == true)
            #expect(log?.contains("\"id\": \"42\"") == true)
        }

        @Test
        func externallyLabelledParameterIsMasked() async throws {
            try await Credentials().register(for: "device-token")

            let log = try #require(capturedLogs.first)
            #expect(log.contains("device-token") == false)
            #expect(log.contains("\"token\": \"************\""))
        }

        @Test
        func resultPropertiesAreMasked() throws {
            _ = try Credentials().member()

            let log = try #require(capturedLogs.first)
            #expect(log.contains("alice@example.com") == false)
            #expect(log.contains("name: Alice"))
        }
    }
}

private struct OptionalEnvelope {
    let sentAt: String
    let payload: Payload?
}

private struct Batch {
    let sentAt: String
    let payloads: [Payload]
}

/// `MaskedValue` must hold wherever the value sits, e.g. inside an array, not just as a direct property.
final class MaskedValueReachabilityTests {
    @Test
    func maskedValueInsideAnOptionalPropertyIsMasked() {
        let described = logDescription(OptionalEnvelope(sentAt: "today", payload: .text(text: "hello there", id: "7")))

        #expect(described.contains("hello there") == false)
    }

    @Test
    func maskedValueInsideATopLevelCollectionIsMasked() {
        let described = logDescription([Payload.text(text: "hello there", id: "7")])

        #expect(described.contains("hello there") == false)
    }

    @Test
    func maskedValueInsideACollectionPropertyIsMasked() {
        let described = logDescription(Batch(sentAt: "today", payloads: [.text(text: "hello there", id: "7")]))

        #expect(described.contains("hello there") == false)
    }

    @Test
    func maskedValueInsideADictionaryValueIsMasked() {
        let described = logDescription(["a": Payload.text(text: "hello there", id: "7")])

        #expect(described.contains("hello there") == false)
    }
}
