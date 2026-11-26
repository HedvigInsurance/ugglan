import AuthenticationCore
import Combine
import Environment
import Foundation
@preconcurrency import HedvigShared
import KMPNativeCoroutinesAsync
import KMPNativeCoroutinesCore
import Logger
import SwiftUI
import TestDependencies
import Testing
import hCore
import hGraphQL

@testable import Ugglan

/// The app's UI tests are the XCUITest suites in Tests/UITests, which build into the AppUITests target. These run
/// hosted by the app, against the real Kotlin framework, without a network request. Serialized because one test
/// registers the network clients in `Dependencies.shared` again; no test swaps the global `log`.
@MainActor
@Suite(.serialized)
struct SharedKotlinTests {
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
        let memberId = try await kotlinRead { Self.succeeding("member") }
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
        do {
            let _: String = try await kotlinRead { Self.failing(kotlinError) }
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

        let messages = try await kotlinRead { Self.succeeding(items) }.map(PublicImportantMessage.init(item:))

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
            let _: [PublicImportantMessageItem] = try await kotlinRead { Self.failing(networkFailure) }
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
        let logger = RecordingLogger()
        let sink = AppLogSink(logger: { logger })

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
        #expect(LogPriority.minimumForKotlin(flavor: .production) == .info)
        #expect(LogPriority.minimumForKotlin(flavor: .staging) == .verbose)
    }

    @Test
    func theLanguageFollowsTheAppLocale() {
        let expected: Language = Localization.Locale.currentLocale.value == .sv_SE ? .svSe : .enSe
        #expect(CurrentLocaleLanguageSource().currentLanguage() == expected)
    }

    @Test
    func theAccessTokenFetcherIsNilOnlyWhenLoggedOutAndOtherwiseRethrows() async throws {
        let token = OAuthorizationToken(
            accessToken: "access",
            accessTokenExpirationDate: .distantFuture,
            refreshToken: "refresh",
            refreshTokenExpirationDate: .distantFuture
        )
        let refreshed = KeychainAccessTokenFetcher(retrieveToken: { token }, refreshIfNeeded: {})
        let loggedOut = KeychainAccessTokenFetcher(
            retrieveToken: { nil },
            refreshIfNeeded: { Issue.record("a logged-out fetch must not refresh") }
        )
        let refreshFailed = KeychainAccessTokenFetcher(
            retrieveToken: { token },
            refreshIfNeeded: { throw AuthError.refreshFailed }
        )
        let keychainFailed = KeychainAccessTokenFetcher(retrieveToken: { throw AuthError.networkIssue })

        #expect(try await refreshed.fetch() == "access")
        #expect(try await loggedOut.fetch() == nil)
        await #expect(throws: AuthError.refreshFailed) { try await refreshFailed.fetch() }
        await #expect(throws: AuthError.networkIssue) { try await keychainFailed.fetch() }
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

/// Each test builds its own view model with a mock client and its own activation and language publishers, so the
/// suite touches no global: no `Dependencies.shared`, no notification posted, no app locale changed.
@MainActor
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

            sut.startObservingImportantMessages()

            await waitUntil(description: "messages loaded") { !sut.importantMessages.isEmpty }
            #expect(sut.importantMessages == [error, warning, info])
            #expect(client.events == [.getMessages])
        }

        await expectViewModelReleased()
    }

    @Test
    func aFailedFirstLoadShowsNothing() async {
        do {
            let client = MockPublicImportantMessagesClient(responses: [{ throw URLError(.notConnectedToInternet) }])
            let sut = makeViewModel(client)

            sut.startObservingImportantMessages()

            await waitUntil(description: "load attempted") { client.events.count == 1 }
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
            sut.startObservingImportantMessages()
            await waitUntil(description: "messages loaded") { !sut.importantMessages.isEmpty }

            appBecameActive.send()

            await waitUntil(description: "reload attempted") { client.events.count == 2 }
            await drainMainQueue()
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
            sut.startObservingImportantMessages()
            await waitUntil(description: "first load finished") { !sut.importantMessages.isEmpty }

            appBecameActive.send()

            await waitUntil(description: "reloaded") { sut.importantMessages == [self.error, self.info] }
            #expect(client.events.count == 2)
        }

        await expectViewModelReleased()
    }

    @Test
    func aLanguageChangeReloadsButTheSameLanguageDoesNot() async {
        do {
            let client = MockPublicImportantMessagesClient(responses: [{ [self.warning] }, { [self.info] }])
            let sut = makeViewModel(client)
            sut.startObservingImportantMessages()
            await waitUntil(description: "first load finished") { !sut.importantMessages.isEmpty }

            locale.send(.sv_SE)
            locale.send(.en_SE)

            await waitUntil(description: "reloaded") { sut.importantMessages == [self.info] }
            #expect(client.events.count == 2)
        }

        await expectViewModelReleased()
    }

    @Test
    func aLateAnswerInTheOldLanguageDoesNotOverwriteTheNewOne() async {
        do {
            let swedishAnswer = Gate()
            let client = MockPublicImportantMessagesClient(responses: [
                {
                    await swedishAnswer.wait()
                    return [self.warning]
                },
                { [self.info] },
            ])
            let sut = makeViewModel(client)
            sut.startObservingImportantMessages()
            await waitUntil(description: "Swedish load started") { client.events.count == 1 }

            locale.send(.en_SE)
            await waitUntil(description: "English answer shown") { sut.importantMessages == [self.info] }
            swedishAnswer.open()
            await drainMainQueue()

            #expect(sut.importantMessages == [info])
            #expect(client.events.count == 2)
        }

        await expectViewModelReleased()
    }

    @Test
    func appearingAgainInTheSameLanguageDoesNotReload() async {
        do {
            let client = MockPublicImportantMessagesClient(responses: [{ [self.warning] }])
            let sut = makeViewModel(client)
            sut.startObservingImportantMessages()
            await waitUntil(description: "first load finished") { !sut.importantMessages.isEmpty }

            sut.stopObservingImportantMessages()
            sut.startObservingImportantMessages()
            sut.startObservingImportantMessages()
            await drainMainQueue()

            #expect(client.events.count == 1)
            #expect(sut.isObservingImportantMessages)
        }

        await expectViewModelReleased()
    }

    /// Logging in removes the screen, so this is also what happens after a login.
    @Test
    func afterTheScreenDisappearsAnActivationOrALanguageChangeDoesNotReload() async {
        do {
            let client = MockPublicImportantMessagesClient(responses: [{ [self.warning] }])
            let sut = makeViewModel(client)
            sut.startObservingImportantMessages()
            await waitUntil(description: "first load finished") { !sut.importantMessages.isEmpty }

            sut.stopObservingImportantMessages()
            appBecameActive.send()
            locale.send(.en_SE)
            await drainMainQueue()

            #expect(client.events.count == 1)
            #expect(!sut.isObservingImportantMessages)
        }

        await expectViewModelReleased()
    }

    @Test
    func disappearingDropsTheAnswerOfARunningLoad() async {
        do {
            let answer = Gate()
            let client = MockPublicImportantMessagesClient(responses: [
                {
                    await answer.wait()
                    return [self.warning]
                }
            ])
            let sut = makeViewModel(client)
            sut.startObservingImportantMessages()
            await waitUntil(description: "load started") { client.events.count == 1 }

            sut.stopObservingImportantMessages()
            answer.open()
            await drainMainQueue()

            #expect(sut.importantMessages.isEmpty)
        }

        await expectViewModelReleased()
    }

    private func makeViewModel(_ client: MockPublicImportantMessagesClient) -> NotLoggedViewModel {
        let sut = NotLoggedViewModel(
            publicImportantMessagesClient: client,
            appBecameActive: appBecameActive.eraseToAnyPublisher(),
            localeChanges: locale.eraseToAnyPublisher()
        )
        vm = sut
        return sut
    }

    private func expectViewModelReleased() async {
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

/// The logged-out screen keeps its cards and buttons below the logo, drawn over the middle of the screen, unless they
/// need the whole height.
@MainActor
struct NotLoggedInLayoutTests {
    @Test
    func theBottomHalfLeavesRoomAboveTheButtonsAndIsNeverNegative() {
        #expect(NotLoggedInView.bottomHalfHeight(of: 800) == 384)
        #expect(NotLoggedInView.bottomHalfHeight(of: 20) == 0)
    }

    @Test
    func contentUpToTheBottomHalfFitsAndTallerContentDoesNot() {
        #expect(NotLoggedInView.fitsTheBottomHalf(contentHeight: 0, screenHeight: 800))
        #expect(NotLoggedInView.fitsTheBottomHalf(contentHeight: 384, screenHeight: 800))
        #expect(NotLoggedInView.fitsTheBottomHalf(contentHeight: 384.5, screenHeight: 800))
        #expect(!NotLoggedInView.fitsTheBottomHalf(contentHeight: 386, screenHeight: 800))
    }

    @Test
    func portraitAtANormalTextSizeNeedsTheWholeHeightOnlyWhenTheContentDoesNotFit() {
        #expect(
            !NotLoggedInView.needsTheWholeHeight(
                verticalSizeClass: .regular,
                dynamicTypeSize: .large,
                contentFitsTheBottomHalf: true
            )
        )
        #expect(
            NotLoggedInView.needsTheWholeHeight(
                verticalSizeClass: .regular,
                dynamicTypeSize: .large,
                contentFitsTheBottomHalf: false
            )
        )
    }

    @Test
    func landscapeAndAccessibilitySizesNeedTheWholeHeightEvenWhenTheContentFits() {
        #expect(
            NotLoggedInView.needsTheWholeHeight(
                verticalSizeClass: .compact,
                dynamicTypeSize: .large,
                contentFitsTheBottomHalf: true
            )
        )
        #expect(
            NotLoggedInView.needsTheWholeHeight(
                verticalSizeClass: .regular,
                dynamicTypeSize: .accessibility1,
                contentFitsTheBottomHalf: true
            )
        )
    }
}

/// Answers with the given responses in order, then with no messages.
@MainActor
private final class MockPublicImportantMessagesClient: PublicImportantMessagesClient {
    enum Event: Equatable {
        case getMessages
    }

    private var responses: [() async throws -> [PublicImportantMessage]]
    private(set) var events: [Event] = []

    init(responses: [() async throws -> [PublicImportantMessage]]) {
        self.responses = responses
    }

    func getMessages() async throws -> [PublicImportantMessage] {
        events.append(.getMessages)
        guard !responses.isEmpty else { return [] }
        return try await responses.removeFirst()()
    }
}

/// Holds an answer back until the test opens it.
@MainActor
private final class Gate {
    private var continuation: CheckedContinuation<Void, Never>?
    private var isOpen = false

    func wait() async {
        guard !isOpen else { return }
        await withCheckedContinuation { continuation = $0 }
    }

    func open() {
        isOpen = true
        continuation?.resume()
        continuation = nil
    }
}
