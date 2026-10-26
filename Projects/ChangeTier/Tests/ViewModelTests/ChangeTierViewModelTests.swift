import Foundation
import TestDependencies
import Testing
import hCore

@testable import ChangeTier
@testable import hCoreUI

extension ChangeTierDependencySuite {
    @MainActor
    final class ChangeTierViewModelTests {
        private weak var sut: MockChangeTierService?
        private weak var vm: ChangeTierViewModel?

        let currentTier = TierFixtures.currentTier
        let tiers = TierFixtures.tiers

        init() {
            ViewModelSuiteSupport.registerDateService()
        }

        private func expectServiceAndViewModelReleased(sourceLocation: SourceLocation = #_sourceLocation) async {
            await ViewModelSuiteSupport.expectServiceAndViewModelReleased(
                viewModel: { self.vm },
                service: { self.sut },
                sourceLocation: sourceLocation
            )
        }

        @Test
        func fetchTiersSuccess() async {
            do {
                let activationDate = "2024-12-12".localDateToDate ?? Date()
                let changeTierIntentModel = TierFixtures.intent(activationDate: activationDate)

                let mockService = MockData.createMockChangeTier(fetchTier: { _ in
                    changeTierIntentModel
                })

                sut = mockService

                let model = ChangeTierViewModel(
                    changeTierInput: .contractWithSource(data: .init(source: .changeTier, contractId: "contractId"))
                )
                vm = model

                await waitUntil(description: "tiers fetched") {
                    model.viewState == .success
                }
                var expectedTiers = tiers
                expectedTiers.insert(currentTier, at: 0)
                #expect(model.tiers == expectedTiers)
                #expect(model.tiers.first == expectedTiers.first)
                #expect(model.tiers.count == expectedTiers.count)
                #expect(model.exposureName == "exposureName")
                #expect(model.displayName == "display name")
                #expect(model.activationDate == activationDate)
                #expect(model.canEditTier)
                #expect(model.viewState == .success)
                #expect(model.selectedTier == currentTier)
            }

            await expectServiceAndViewModelReleased()
        }

        @Test
        func contractIdFromContractWithSource() async {
            do {
                let mockService = MockData.createMockChangeTier()
                sut = mockService

                let model = ChangeTierViewModel(
                    changeTierInput: .contractWithSource(data: .init(source: .changeTier, contractId: "contract-123"))
                )
                vm = model

                #expect(model.contractId == "contract-123")
            }

            await expectServiceAndViewModelReleased()
        }

        @Test
        func contractIdFromExistingIntent() async {
            do {
                let mockService = MockData.createMockChangeTier()
                sut = mockService

                let intent = TierFixtures.intent(contractId: "intent-contract-456", activationDate: Date())

                let model = ChangeTierViewModel(
                    changeTierInput: .existingIntent(intent: intent, onSelect: nil)
                )
                vm = model

                #expect(model.contractId == "intent-contract-456")
            }

            await expectServiceAndViewModelReleased()
        }

        @Test
        func addCampaingCodeViewModelFailure() async {
            do {
                let mockService = MockData.createMockChangeTier(
                    fetchTier: { _ throws(ChangeTierError) in
                        throw ChangeTierError.somethingWentWrong
                    }
                )

                sut = mockService

                let model = ChangeTierViewModel(
                    changeTierInput: .contractWithSource(data: .init(source: .changeTier, contractId: "contractId"))
                )
                vm = model
                model.fetchTiers()
                await waitUntil(description: "tiers fetch failed") {
                    model.viewState == .error(errorMessage: ChangeTierError.somethingWentWrong.localizedDescription)
                }
                #expect(model.canEditTier == false)
                #expect(model.tiers.isEmpty)
                #expect(model.exposureName == nil)
                #expect(model.displayName == nil)
                #expect(model.activationDate == nil)
                #expect(model.selectedTier == nil)

                #expect(
                    model.viewState == .error(errorMessage: ChangeTierError.somethingWentWrong.localizedDescription)
                )
            }

            await expectServiceAndViewModelReleased()
        }

        @Test
        func setSelectedTierSuccess() async {
            do {
                let activationDate = "2024-12-12".localDateToDate ?? Date()
                let changeTierIntentModel = TierFixtures.intent(activationDate: activationDate)

                let mockService = MockData.createMockChangeTier(fetchTier: { _ in
                    changeTierIntentModel
                })

                sut = mockService

                let model = ChangeTierViewModel(
                    changeTierInput: .contractWithSource(data: .init(source: .changeTier, contractId: "contractId"))
                )
                vm = model
                model.fetchTiers()
                await waitUntil(description: "tiers fetched") {
                    model.viewState == .success
                }
                model.setTier(for: "max")
                #expect(model.selectedTier?.name == "max")
                #expect(model.selectedTier == tiers[1])
                #expect(model.exposureName == "exposureName")
                #expect(model.displayName == "displayName")
                #expect(model.activationDate == activationDate)
                #expect(model.canEditTier)
                #expect(model.viewState == .success)
            }

            await expectServiceAndViewModelReleased()
        }

        @Test
        func setSelectedTierFailure() async {
            do {
                let mockService = MockData.createMockChangeTier(
                    fetchTier: { _ throws(ChangeTierError) in
                        throw ChangeTierError.somethingWentWrong
                    }
                )

                sut = mockService

                let model = ChangeTierViewModel(
                    changeTierInput: .contractWithSource(data: .init(source: .changeTier, contractId: "contractId"))
                )
                vm = model
                model.fetchTiers()
                await waitUntil(description: "tiers fetch failed") {
                    model.viewState == .error(errorMessage: ChangeTierError.somethingWentWrong.localizedDescription)
                }
                model.setTier(for: "max")
                #expect(model.selectedTier == nil)
                #expect(model.canEditTier == false)
                #expect(model.tiers.isEmpty)
                #expect(model.exposureName == nil)
                #expect(model.displayName == nil)
                #expect(model.activationDate == nil)
                #expect(model.selectedTier == nil)
                #expect(
                    model.viewState == .error(errorMessage: ChangeTierError.somethingWentWrong.localizedDescription)
                )
            }

            await expectServiceAndViewModelReleased()
        }

        @Test
        func setSelectedDeductibleSuccess() async {
            do {
                let activationDate = "2024-12-12".localDateToDate ?? Date()
                let changeTierIntentModel = TierFixtures.intent(activationDate: activationDate, currentTier: nil)

                let mockService = MockData.createMockChangeTier(fetchTier: { _ in
                    changeTierIntentModel
                })

                sut = mockService

                let model = ChangeTierViewModel(
                    changeTierInput: .contractWithSource(data: .init(source: .changeTier, contractId: "contractId"))
                )
                vm = model
                await waitUntil(description: "tiers fetched") {
                    model.viewState == .success
                }
                model.setTier(for: "max")
                model.setDeductible(for: model.selectedTier?.quotes.first?.id ?? "")
                #expect(model.selectedQuote != nil)
                #expect(model.selectedQuote?.id == model.selectedTier?.quotes.first?.id)
                #expect(model.selectedTier == tiers[1])
                #expect(model.selectedQuote == tiers[1].quotes[0])
                #expect(model.tiers == tiers)
                #expect(model.tiers.first == tiers.first)
                #expect(model.tiers.count == tiers.count)
                #expect(model.exposureName == "exposureName")
                #expect(model.displayName == "displayName")
                #expect(model.activationDate == activationDate)
                #expect(model.canEditTier)
                #expect(model.viewState == .success)
            }

            await expectServiceAndViewModelReleased()
        }

        @Test
        func setSelectedDeductibleFailure() async {
            do {
                let mockService = MockData.createMockChangeTier(
                    fetchTier: { _ throws(ChangeTierError) in
                        throw ChangeTierError.somethingWentWrong
                    }
                )

                sut = mockService

                let model = ChangeTierViewModel(
                    changeTierInput: .contractWithSource(data: .init(source: .changeTier, contractId: "contractId"))
                )
                vm = model
                model.fetchTiers()
                model.setTier(for: "max")
                model.setDeductible(for: model.selectedTier?.quotes.first?.id ?? "")
                #expect(model.selectedQuote == nil)
                #expect(model.selectedTier == nil)
                #expect(model.canEditTier == false)
                #expect(model.tiers.isEmpty)
                #expect(model.exposureName == nil)
                #expect(model.displayName == nil)
                #expect(model.activationDate == nil)
                #expect(model.selectedTier == nil)
                await waitUntil(description: "tiers fetch failed") {
                    model.viewState == .error(errorMessage: ChangeTierError.somethingWentWrong.localizedDescription)
                }
                #expect(
                    model.viewState == .error(errorMessage: ChangeTierError.somethingWentWrong.localizedDescription)
                )
            }

            await expectServiceAndViewModelReleased()
        }

        @Test
        func processingTextUsesPaymentProtectionCopyBeforeTiersAreFetched() async {
            do {
                let mockService = MockData.createMockChangeTier()
                sut = mockService

                let model = ChangeTierViewModel(
                    changeTierInput: .contractWithSource(
                        data: .init(source: .changeTier, contractId: "contractId", typeOfContract: .sePaymentProtection)
                    )
                )
                vm = model

                //the loading text is on screen before the fetch resolves, so no waiting here on purpose
                #expect(model.isPaymentProtection)
                #expect(model.processingText == L10n.changeInsuranceAmountProcessing)
            }

            await expectServiceAndViewModelReleased()
        }

        @Test
        func processingTextUsesCoverageCopyForNonPaymentProtectionContracts() async {
            do {
                let mockService = MockData.createMockChangeTier()
                sut = mockService

                let model = ChangeTierViewModel(
                    changeTierInput: .contractWithSource(
                        data: .init(source: .changeTier, contractId: "contractId", typeOfContract: .seHouse)
                    )
                )
                vm = model

                #expect(!model.isPaymentProtection)
                #expect(model.processingText == L10n.tierFlowProcessing)
            }

            await expectServiceAndViewModelReleased()
        }

        @Test
        func processingTextFallsBackToCoverageCopyWhenTypeOfContractIsUnknown() async {
            do {
                let mockService = MockData.createMockChangeTier()
                sut = mockService

                let model = ChangeTierViewModel(
                    changeTierInput: .contractWithSource(data: .init(source: .changeTier, contractId: "contractId"))
                )
                vm = model

                #expect(!model.isPaymentProtection)
                #expect(model.processingText == L10n.tierFlowProcessing)
            }

            await expectServiceAndViewModelReleased()
        }
    }
}
