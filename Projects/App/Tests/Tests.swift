import Environment
import Foundation
@preconcurrency import HedvigShared
import KMPNativeCoroutinesAsync
import KMPNativeCoroutinesCore
import Logger
import Testing
import hCore
import hGraphQL

@testable import Ugglan

/// The app's UI tests are the XCUITest suites in Tests/UITests, which build into the AppUITests target. These run
/// hosted by the app, against the real Kotlin framework, without a network request. Serialized because they swap the
/// global `log` and use `Dependencies.shared`.
@MainActor
@Suite(.serialized)
struct SharedKotlinTests {
    /// What a client backed by a Kotlin read looks like. No read ships in the framework yet, so the test passes the
    /// call a feature would make, `holder.fooReads().bar()`, as a closure.
    @MainActor
    private struct ExampleClient {
        let memberIdRead: () -> NativeSuspend<String, Error, KotlinUnit>

        func memberId() async throws -> String {
            do {
                return try await asyncFunction(for: memberIdRead())
            } catch {
                throw GraphQLError(readError: error)
            }
        }
    }

    @Test
    func theGraphHolderIsRegisteredOncePerProcess() async {
        await DI.initNetworkClients()
        let first: IosGraphHolder = Dependencies.shared.resolve()
        await DI.initNetworkClients()
        let second: IosGraphHolder = Dependencies.shared.resolve()
        #expect(first === second)
    }

    @Test
    func aReadReturnsItsValue() async throws {
        let client = ExampleClient(memberIdRead: { Self.succeeding("member") })
        let memberId = try await client.memberId()
        #expect(memberId == "member")
    }

    @Test
    func aFailedReadThrowsWhatAnOctopusClientWould() async {
        #expect(await isGraphQLError(afterFailureOf: .network) == false)
        #expect(await isGraphQLError(afterFailureOf: .unauthenticated) == true)
        #expect(await isGraphQLError(afterFailureOf: .other) == true)
    }

    private func isGraphQLError(afterFailureOf kind: ReadFailureKind) async -> Bool? {
        let kotlinError = NSError(
            domain: "KotlinException",
            code: 0,
            userInfo: ["KotlinException": ReadFailure(kind: kind, cause: nil)]
        )
        let client = ExampleClient(memberIdRead: { Self.failing(kotlinError) })
        do {
            _ = try await client.memberId()
            return nil
        } catch let error as GraphQLError {
            if case .graphQLError = error { return true }
            return false
        } catch {
            return nil
        }
    }

    @Test
    func anErrorThatIsNotAReadFailureIsAnOtherError() {
        let cancel = CancellationError()
        guard case let .otherError(error) = GraphQLError(readError: cancel) else {
            Issue.record("expected .otherError")
            return
        }
        #expect(error is CancellationError)
    }

    @Test
    func kotlinLinesAreHeldUntilTheLoggerIsReadyThenWrittenInOrder() async {
        let sink = AppLogSink()
        let logger = RecordingLogger()
        let previous = hCore.log
        hCore.log = logger
        defer { hCore.log = previous }

        sink.log(priority: .info, tag: "T", message: "first")
        sink.log(priority: .warn, tag: nil, message: "second")
        await Self.drainMainQueue()
        #expect(logger.lines.isEmpty)

        sink.logIsReady()
        sink.log(priority: .verbose, tag: nil, message: "third")
        sink.log(priority: .error, tag: nil, message: "fourth")
        sink.log(priority: .assert, tag: nil, message: "fifth")
        await Self.drainMainQueue()

        #expect(logger.lines.map(\.message) == ["first", "second", "third", "fourth", "fifth"])
        #expect(logger.lines.map(\.level) == ["info", "warn", "debug", "error", "critical"])
    }

    @Test
    func productionNeverLogsMemberData() {
        #expect(Environment.production.flavor == .production)
        #expect(Environment.staging.flavor == .staging)
        let production = NetworkLogPolicy(flavor: .production)
        #expect(!production.logsHttpBodies && !production.logsGraphqlData && production.logsGraphqlErrors)
        let staging = NetworkLogPolicy(flavor: .staging)
        #expect(staging.logsHttpBodies && staging.logsGraphqlData && staging.logsGraphqlErrors)
    }

    @Test
    func theLanguageFollowsTheAppLocale() {
        let expected: Language = Localization.Locale.currentLocale.value == .sv_SE ? .svSe : .enSe
        #expect(CurrentLocaleLanguageSource().currentLanguage() == expected)
    }

    private static func succeeding<T>(_ value: T) -> NativeSuspend<T, Error, KotlinUnit> {
        { onResult, _, _ in
            _ = onResult(value, KotlinUnit())
            return { KotlinUnit() }
        }
    }

    private static func failing<T>(_ error: Error) -> NativeSuspend<T, Error, KotlinUnit> {
        { _, onError, _ in
            _ = onError(error, KotlinUnit())
            return { KotlinUnit() }
        }
    }

    private static func drainMainQueue() async {
        await withCheckedContinuation { continuation in
            DispatchQueue.main.async { continuation.resume() }
        }
    }
}

@MainActor
private final class RecordingLogger: Logging {
    struct Line {
        let level: String
        let message: String
    }

    var lines: [Line] = []

    private nonisolated func record(_ level: String, _ message: String) {
        MainActor.assumeIsolated { lines.append(Line(level: level, message: message)) }
    }

    nonisolated func debug(_ message: String, error _: Error?, attributes _: [AttributeKey: AttributeValue]?) {
        record("debug", message)
    }

    nonisolated func info(_ message: String, error _: Error?, attributes _: [AttributeKey: AttributeValue]?) {
        record("info", message)
    }

    nonisolated func notice(_ message: String, error _: Error?, attributes _: [AttributeKey: AttributeValue]?) {
        record("notice", message)
    }

    nonisolated func warn(_ message: String, error _: Error?, attributes _: [AttributeKey: AttributeValue]?) {
        record("warn", message)
    }

    nonisolated func error(_ message: String, error _: Error?, attributes _: [AttributeKey: AttributeValue]?) {
        record("error", message)
    }

    nonisolated func critical(_ message: String, error _: Error?, attributes _: [AttributeKey: AttributeValue]?) {
        record("critical", message)
    }

    nonisolated func addUserAction(
        type _: LoggingAction,
        name _: String,
        error _: Error?,
        attributes _: [AttributeKey: AttributeValue]?
    ) {}

    nonisolated func addError(error _: Error, type _: ErrorSource, attributes _: [AttributeKey: AttributeValue]?) {}
}
