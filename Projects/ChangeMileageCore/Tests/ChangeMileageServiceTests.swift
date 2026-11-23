import Foundation
import TestDependencies
import Testing
import hCore

@testable import ChangeMileageCore

extension ChangeMileageDependencySuite {
    @MainActor
    final class ChangeMileageServiceTests {
        private weak var sut: MockChangeMileageClient?

        private func expectClientReleased() async {
            Dependencies.shared.remove(for: ChangeMileageClient.self)
            await delay(0.0000001)
            #expect(sut == nil, "the mock client must not outlive its dependency registration")
        }

        @Test
        func createIntentReturnsTheClientsIntent() async {
            await recordingErrors {
                let client = MockData.createMockChangeMileage()
                sut = client

                let intent = try await ChangeMileageService().createIntent(contractId: "contractId")

                #expect(intent == MileageFixtures.intent)
                #expect(client.events == [.createIntent(contractId: "contractId")])
            }
            await expectClientReleased()
        }

        @Test
        func commitIntentForwardsTheQuoteId() async {
            await recordingErrors {
                let client = MockData.createMockChangeMileage()
                sut = client

                try await ChangeMileageService().commitIntent(quoteId: "lower")

                #expect(client.events == [.commitIntent(quoteId: "lower")])
            }
            await expectClientReleased()
        }

        @Test
        func userErrorIsShownAsIs() async {
            do {
                sut = MockData.createMockChangeMileage(createIntent: { _ in
                    throw ChangeMileageError.userError(message: "Not now")
                })
                do {
                    _ = try await ChangeMileageService().createIntent(contractId: "contractId")
                    Issue.record("expected an error")
                } catch {
                    #expect(error.localizedDescription == "Not now")
                }
            }
            await expectClientReleased()
        }
    }
}
