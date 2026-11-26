import AuthenticationCore
import Foundation
import TestDependencies
import Testing
import hCore

@testable import Ugglan

/// The view decides when to load (appearing, becoming active, a language change) through `.task(id:)`; these cover
/// what a load does. Each test passes its own client, so the suite touches no global.
@MainActor
final class NotLoggedViewModelTests {
    private weak var vm: NotLoggedViewModel?

    private let error = PublicImportantMessage(id: "error", message: "a", severity: .error, link: nil)
    private let warning = PublicImportantMessage(
        id: "warning",
        message: "b",
        severity: .warning,
        link: .init(url: URL(string: "https://example.test")!, text: "Read more")
    )
    private let info = PublicImportantMessage(id: "info", message: "c", severity: .info, link: nil)

    @Test
    func loadShowsTheMessagesInTheOrderGiven() async {
        do {
            let client = MockPublicImportantMessagesClient(responses: [{ [self.error, self.warning, self.info] }])
            let sut = makeViewModel(client)

            await sut.loadImportantMessages()

            #expect(sut.importantMessages == [error, warning, info])
            #expect(client.events == [.getMessages])
        }

        await expectViewModelReleased()
    }

    @Test
    func loadFailureFirstShowsNothing() async {
        do {
            let client = MockPublicImportantMessagesClient(responses: [{ throw URLError(.notConnectedToInternet) }])
            let sut = makeViewModel(client)

            await sut.loadImportantMessages()

            #expect(sut.importantMessages.isEmpty)
            #expect(client.events == [.getMessages])
        }

        await expectViewModelReleased()
    }

    @Test
    func reloadReplacesTheList() async {
        do {
            let client = MockPublicImportantMessagesClient(responses: [{ [self.warning] }, { [self.error, self.info] }])
            let sut = makeViewModel(client)

            await sut.loadImportantMessages()
            await sut.loadImportantMessages()

            #expect(sut.importantMessages == [error, info])
            #expect(client.events.count == 2)
        }

        await expectViewModelReleased()
    }

    @Test
    func reloadFailureKeepsTheLastList() async {
        do {
            let client = MockPublicImportantMessagesClient(responses: [
                { [self.warning] },
                { throw URLError(.notConnectedToInternet) },
            ])
            let sut = makeViewModel(client)

            await sut.loadImportantMessages()
            await sut.loadImportantMessages()

            #expect(sut.importantMessages == [warning])
            #expect(client.events.count == 2)
        }

        await expectViewModelReleased()
    }

    @Test
    func cancelledLoadDropsItsAnswer() async {
        do {
            let answer = Gate()
            let client = MockPublicImportantMessagesClient(responses: [
                { [self.warning] },
                {
                    await answer.wait()
                    return [self.info]
                },
            ])
            let sut = makeViewModel(client)
            await sut.loadImportantMessages()

            let load = Task { await sut.loadImportantMessages() }
            await waitUntil(description: "the second load started") { client.events.count == 2 }
            load.cancel()
            answer.open()
            await load.value

            #expect(sut.importantMessages == [warning])
        }

        await expectViewModelReleased()
    }

    private func makeViewModel(_ client: MockPublicImportantMessagesClient) -> NotLoggedViewModel {
        let sut = NotLoggedViewModel(publicImportantMessagesClient: client)
        vm = sut
        return sut
    }

    private func expectViewModelReleased() async {
        await waitUntil(description: "the view model is released") { self.vm == nil }
    }
}
