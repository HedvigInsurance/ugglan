import AuthenticationCore
import Combine
import Environment
import Foundation
@preconcurrency import HedvigShared
import KMPNativeCoroutinesAsync
import KMPNativeCoroutinesCore
import Logger
import TestDependencies
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
    func publicImportantMessagesMapToTheSwiftModel() async throws {
        let items = [
            PublicImportantMessageItem(
                id: "error-1",
                message: "a",
                severity: .error,
                linkUrl: "https://example.test/status",
                linkButtonText: "Status"
            ),
            PublicImportantMessageItem(id: "info-1", message: "b", severity: .info, linkUrl: nil, linkButtonText: nil),
            PublicImportantMessageItem(
                id: "warning-1",
                message: "c",
                severity: .warning,
                linkUrl: "hedvig://chat",
                linkButtonText: "Chat"
            ),
        ]

        let messages = try await PublicImportantMessagesClientShared.messages(from: { Self.succeeding(items) })

        #expect(
            messages == [
                PublicImportantMessage(
                    id: "error-1",
                    message: "a",
                    severity: .error,
                    link: .init(url: URL(string: "https://example.test/status")!, text: "Status")
                ),
                PublicImportantMessage(id: "info-1", message: "b", severity: .info, link: nil),
                PublicImportantMessage(id: "warning-1", message: "c", severity: .warning, link: nil),
            ]
        )
    }

    @Test
    func aFailedPublicImportantMessagesReadThrowsAGraphQLError() async {
        let networkFailure = NSError(
            domain: "KotlinException",
            code: 0,
            userInfo: ["KotlinException": ReadFailure(kind: .network, cause: nil)]
        )
        do {
            _ = try await PublicImportantMessagesClientShared.messages(from: { Self.failing(networkFailure) })
            Issue.record("expected the read to throw")
        } catch let error as GraphQLError {
            guard case .otherError = error else {
                Issue.record("expected .otherError for a network failure")
                return
            }
        } catch {
            Issue.record("expected a GraphQLError")
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

/// Serialized because each test swaps the `PublicImportantMessagesClient` in `Dependencies.shared`. The view model
/// gets its activation and language publishers passed in, so no test posts a notification or changes the app locale.
@MainActor
@Suite(.serialized)
final class NotLoggedViewModelTests {
    private weak var vm: NotLoggedViewModel?
    private let appBecameActive = PassthroughSubject<Void, Never>()
    private let locale = CurrentValueSubject<Localization.Locale, Never>(.sv_SE)

    private let error = PublicImportantMessage(id: "error", message: "a", severity: .error, link: nil)
    private let warning = PublicImportantMessage(
        id: "warning",
        message: "b",
        severity: .warning,
        link: .init(url: URL(string: "https://example.test")!, text: "Read more")
    )
    private let info = PublicImportantMessage(id: "info", message: "c", severity: .info, link: nil)

    @Test
    func theFirstAppearanceLoadsTheMessagesInTheOrderGiven() async {
        do {
            let client = MockPublicImportantMessagesClient(responses: [{ [self.error, self.warning, self.info] }])
            let sut = makeViewModel(client)

            sut.startLoadingImportantMessages()

            await waitUntil(description: "messages loaded") { !sut.importantMessages.isEmpty }
            #expect(sut.importantMessages == [error, warning, info])
            #expect(client.calls == 1)
        }

        await expectViewModelReleased()
    }

    @Test
    func aFailedFirstLoadShowsNothing() async {
        do {
            let client = MockPublicImportantMessagesClient(responses: [{ throw URLError(.notConnectedToInternet) }])
            let sut = makeViewModel(client)

            sut.startLoadingImportantMessages()

            await waitUntil(description: "load attempted") { client.calls == 1 }
            await drainMainQueue()
            #expect(sut.importantMessages.isEmpty)
        }

        await expectViewModelReleased()
    }

    @Test
    func aFailedReloadKeepsTheLastList() async {
        do {
            let client = MockPublicImportantMessagesClient(responses: [
                { [self.warning] },
                { throw URLError(.notConnectedToInternet) },
            ])
            let sut = makeViewModel(client)
            sut.startLoadingImportantMessages()
            await waitUntil(description: "messages loaded") { !sut.importantMessages.isEmpty }
            await waitUntil(description: "first load finished") { !sut.isLoadingImportantMessages }

            appBecameActive.send()

            await waitUntil(description: "reload attempted") { client.calls == 2 }
            await waitUntil(description: "reload finished") { !sut.isLoadingImportantMessages }
            #expect(sut.importantMessages == [warning])
        }

        await expectViewModelReleased()
    }

    @Test
    func becomingActiveReloads() async {
        do {
            let client = MockPublicImportantMessagesClient(responses: [
                { [self.warning] }, { [self.error, self.info] },
            ])
            let sut = makeViewModel(client)
            sut.startLoadingImportantMessages()
            await waitUntil(description: "first load finished") {
                !sut.importantMessages.isEmpty && !sut.isLoadingImportantMessages
            }

            appBecameActive.send()

            await waitUntil(description: "reloaded") { sut.importantMessages == [self.error, self.info] }
            #expect(client.calls == 2)
        }

        await expectViewModelReleased()
    }

    @Test
    func aLanguageChangeReloadsButTheSameLanguageDoesNot() async {
        do {
            let client = MockPublicImportantMessagesClient(responses: [{ [self.warning] }, { [self.info] }])
            let sut = makeViewModel(client)
            sut.startLoadingImportantMessages()
            await waitUntil(description: "first load finished") {
                !sut.importantMessages.isEmpty && !sut.isLoadingImportantMessages
            }

            locale.send(.sv_SE)
            locale.send(.en_SE)

            await waitUntil(description: "reloaded") { sut.importantMessages == [self.info] }
            #expect(client.calls == 2)
        }

        await expectViewModelReleased()
    }

    @Test
    func appearingAgainDoesNotReload() async {
        do {
            let client = MockPublicImportantMessagesClient(responses: [{ [self.warning] }])
            let sut = makeViewModel(client)
            sut.startLoadingImportantMessages()
            await waitUntil(description: "first load finished") {
                !sut.importantMessages.isEmpty && !sut.isLoadingImportantMessages
            }

            sut.startLoadingImportantMessages()
            await drainMainQueue()

            #expect(client.calls == 1)
        }

        await expectViewModelReleased()
    }

    private func makeViewModel(_ client: MockPublicImportantMessagesClient) -> NotLoggedViewModel {
        Dependencies.shared.add(module: Module { () -> PublicImportantMessagesClient in client })
        let sut = NotLoggedViewModel(
            appBecameActive: appBecameActive.eraseToAnyPublisher(),
            localeChanges: locale.eraseToAnyPublisher()
        )
        vm = sut
        return sut
    }

    /// Puts back the client the hosting app registered, so its own login screen keeps working.
    private func expectViewModelReleased() async {
        Dependencies.shared.add(
            module: Module { () -> PublicImportantMessagesClient in
                PublicImportantMessagesClientShared()
            }
        )
        await waitUntil(description: "the view model is released") { self.vm == nil }
    }

    private func drainMainQueue() async {
        for _ in 0..<3 {
            await withCheckedContinuation { continuation in
                DispatchQueue.main.async { continuation.resume() }
            }
        }
    }
}

@MainActor
private final class MockPublicImportantMessagesClient: PublicImportantMessagesClient {
    private var responses: [() throws -> [PublicImportantMessage]]
    private(set) var calls = 0

    init(responses: [() throws -> [PublicImportantMessage]]) {
        self.responses = responses
    }

    func getMessages() async throws -> [PublicImportantMessage] {
        calls += 1
        return try responses.removeFirst()()
    }
}
