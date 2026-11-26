import AuthenticationCore
import Combine
import Foundation
import TestDependencies
import Testing
import hCore

@testable import Ugglan

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
