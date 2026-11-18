import ChangeMileageCore
import Foundation
import TestDependencies
import Testing
import hCore

@testable import ChangeMileageUI
@testable import hCoreUI

extension ChangeMileageDependencySuite {
    @MainActor
    final class ChangeMileageViewModelTests {
        private weak var client: MockChangeMileageClient?
        private weak var vm: ChangeMileageViewModel?

        // Remove the client only after the view model's Task finishes; removing it earlier makes @Inject fatalError.
        private func expectClientAndViewModelReleased(sourceLocation: SourceLocation = #_sourceLocation) async {
            await waitUntil(description: "the view model must not outlive the test that created it") {
                self.vm == nil
            }
            Dependencies.shared.remove(for: ChangeMileageClient.self)
            await delay(0.02)
            #expect(client == nil, "the mock client must not outlive its registration", sourceLocation: sourceLocation)
        }

        @Test
        func currentMileageIsPreselectedAndCannotBeContinuedWith() async {
            do {
                client = MockData.createMockChangeMileage()
                let model = ChangeMileageViewModel(contract: MileageFixtures.contract)
                vm = model

                await waitUntil(description: "intent loaded") { model.viewState == .success }

                #expect(model.selectedQuote == MileageFixtures.currentQuote)
                #expect(model.isCurrentSelected)
                #expect(!model.isLowerThanCurrentSelected)
                #expect(client?.events == [.createIntent(contractId: "contractId")])
            }
            await expectClientAndViewModelReleased()
        }

        @Test
        func pickingALowerMileageShowsTheLowerCompensationNotice() async {
            do {
                client = MockData.createMockChangeMileage()
                let model = ChangeMileageViewModel(contract: MileageFixtures.contract)
                vm = model
                await waitUntil(description: "intent loaded") { model.viewState == .success }

                model.select(quoteId: MileageFixtures.lowerQuote.id)
                #expect(!model.isCurrentSelected)
                #expect(model.isLowerThanCurrentSelected)

                model.select(quoteId: MileageFixtures.higherQuote.id)
                #expect(!model.isCurrentSelected)
                #expect(!model.isLowerThanCurrentSelected)
            }
            await expectClientAndViewModelReleased()
        }

        @Test
        func userErrorIsShownWithItsMessage() async {
            do {
                client = MockData.createMockChangeMileage(createIntent: { _ in
                    throw ChangeMileageError.userError(message: "Not now")
                })
                let model = ChangeMileageViewModel(contract: MileageFixtures.contract)
                vm = model

                await waitUntil(description: "intent failed") { model.viewState != .loading }
                #expect(model.viewState == .error(errorMessage: "Not now"))
            }
            await expectClientAndViewModelReleased()
        }

        @Test
        func committingSendsTheSelectedQuote() async {
            do {
                client = MockData.createMockChangeMileage()
                let model = ChangeMileageViewModel(contract: MileageFixtures.contract)
                vm = model
                await waitUntil(description: "intent loaded") { model.viewState == .success }

                model.select(quoteId: MileageFixtures.higherQuote.id)
                model.commit()

                await waitUntil(description: "commit finished") { model.commitState == .success }
                #expect(client?.events.last == .commitIntent(quoteId: MileageFixtures.higherQuote.id))
            }
            await expectClientAndViewModelReleased()
        }

        @Test
        func failedCommitShowsAnError() async {
            do {
                client = MockData.createMockChangeMileage(commitIntent: { _ in
                    throw ChangeMileageError.somethingWentWrong
                })
                let model = ChangeMileageViewModel(contract: MileageFixtures.contract)
                vm = model
                await waitUntil(description: "intent loaded") { model.viewState == .success }

                model.select(quoteId: MileageFixtures.lowerQuote.id)
                model.commit()

                await waitUntil(description: "commit failed") { model.commitState != .loading }
                #expect(model.commitState == .error(errorMessage: L10n.General.errorBody))
            }
            await expectClientAndViewModelReleased()
        }
    }
}
