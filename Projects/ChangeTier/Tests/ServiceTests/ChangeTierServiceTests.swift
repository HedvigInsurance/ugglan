import Foundation
import TestDependencies
import Testing
import hCore

@testable import ChangeTier

extension ChangeTierDependencySuite {
    @MainActor
    final class ChangeTierServiceTests {
        private weak var sut: MockChangeTierService?

        // Test bodies are scoped so their locals are released before this check runs.
        private func expectServiceReleased() async {
            Dependencies.shared.remove(for: ChangeTierClient.self)
            await delay(0.0000001)
            #expect(sut == nil, "the mock service must not outlive its dependency registration")
        }

        @Test
        func fetchTierDataSuccess() async {
            await recordingErrors {
                let tiers = TierFixtures.tiers

                let changeTierIntentModel: ChangeTierIntentModel = .init(
                    contractId: "contractId",
                    displayName: "displayName",
                    activationDate: Date(),
                    tiers: tiers,
                    currentTier: nil,
                    currentQuote: nil,
                    selectedTier: nil,
                    selectedQuote: nil,
                    canEditTier: true,
                    typeOfContract: .seHouse,
                    relatedAddons: [:]
                )

                let mockService = MockData.createMockChangeTier(fetchTier: { _ in
                    changeTierIntentModel
                })

                sut = mockService

                let respondedTiersData = try await mockService.getTier(
                    input: .init(source: .changeTier, contractId: "contractId")
                )
                if case let .changeTierIntentModel(data) = respondedTiersData {
                    #expect(data == changeTierIntentModel)
                } else {
                    Issue.record("shouldn't happen")
                }
            }

            await expectServiceReleased()
        }

        @Test
        func compareProductVariantDataSuccess() async {
            await recordingErrors {
                let rows: [ProductVariantComparison.ProductVariantComparisonRow] = [
                    .init(
                        title: "rowTitle",
                        description: "description",
                        colorCode: nil,
                        cells: [
                            .init(isCovered: true, coverageText: nil)
                        ]
                    )
                ]

                let columns: [ProductVariant] = [
                    .init(
                        termsVersion: "",
                        typeOfContract: "",
                        perils: [],
                        insurableLimits: [],
                        documents: [],
                        displayName: "",
                        displayNameTier: "Standard",
                        tierDescription: "tier description"
                    )
                ]

                let comparisonData = ProductVariantComparison(rows: rows, variantColumns: columns)

                let mockService = MockData.createMockChangeTier(compareProductVariants: { _ in
                    comparisonData
                })

                sut = mockService

                let responedComparisonData = try await mockService.compareProductVariants(termsVersion: [])

                #expect(responedComparisonData == comparisonData)
            }

            await expectServiceReleased()
        }
    }
}
