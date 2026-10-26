import TestDependencies
import Testing
import hCore

@testable import ChangeTier
@testable import hCoreUI

extension ChangeTierDependencySuite {
    @MainActor
    final class CompareTierViewModelTests {
        private weak var sut: MockChangeTierService?
        private weak var vm: CompareTierViewModel?

        let currentTier = TierFixtures.currentTier
        let tiers = TierFixtures.tiers

        init() {
            Dependencies.shared.add(module: Module { () -> DateService in DateService() })
        }

        // Remove the client only after the view model's Task finishes; removing it earlier makes @Inject fatalError.
        private func expectServiceAndViewModelReleased() async {
            await waitUntil(description: "the view model must not outlive the test that created it") {
                self.vm == nil
            }
            Dependencies.shared.remove(for: ChangeTierClient.self)
            Dependencies.shared.remove(for: DateService.self)
            await delay(0.02)
            #expect(sut == nil, "the mock service must not outlive its dependency registration")
        }

        @Test
        func compareTiersSuccess() async {
            await recordingErrors {
                let peril1 = Perils(
                    id: "peril1",
                    title: "peril1",
                    description: "description",
                    color: nil,
                    covered: [""],
                    isDisabled: false
                )

                let rows: [ProductVariantComparison.ProductVariantComparisonRow] = [
                    .init(
                        title: peril1.title,
                        description: peril1.description,
                        colorCode: peril1.color,
                        cells: [
                            .init(isCovered: !peril1.isDisabled, coverageText: peril1.covered.first),
                            .init(isCovered: !peril1.isDisabled, coverageText: peril1.covered.first),
                        ]
                    )
                ]

                let columns: [ProductVariant] = [
                    .init(
                        termsVersion: "",
                        typeOfContract: "",
                        perils: [peril1],
                        insurableLimits: [],
                        documents: [],
                        displayName: "",
                        displayNameTier: "Standard",
                        tierDescription: "tier description"
                    ),
                    .init(
                        termsVersion: "",
                        typeOfContract: "",
                        perils: [peril1],
                        insurableLimits: [],
                        documents: [],
                        displayName: "",
                        displayNameTier: "Max",
                        tierDescription: "tier description"
                    ),
                ]

                let comparisonData = ProductVariantComparison(rows: rows, variantColumns: columns)

                let mockService = MockData.createMockChangeTier(compareProductVariants: { _ in
                    comparisonData
                })

                sut = mockService

                let model = CompareTierViewModel(tiers: tiers)
                vm = model
                model.productVariantComparision()

                await waitUntil(description: "product variants compared") {
                    model.viewState == .success
                }
                #expect(model.tiers == tiers)
                #expect(model.tiers.first == tiers.first)
                #expect(model.tiers.count == tiers.count)
                let first = try #require(model.perils.first)
                #expect(first == ("Standard", [peril1]))
                #expect(model.viewState == .success)
            }

            await expectServiceAndViewModelReleased()
        }

        @Test
        func compareTiersFailure() async {
            do {
                let mockService = MockData.createMockChangeTier(compareProductVariants: { _ in
                    throw ChangeTierError.somethingWentWrong
                })

                sut = mockService

                let model = CompareTierViewModel(tiers: tiers)
                vm = model
                model.productVariantComparision()

                await waitUntil(description: "product variant comparison failed") {
                    model.viewState == .error(errorMessage: ChangeTierError.somethingWentWrong.localizedDescription)
                }
                #expect(model.tiers == tiers)
                #expect(model.tiers.first == tiers.first)
                #expect(model.tiers.count == tiers.count)
                #expect(model.perils.isEmpty)
                #expect(
                    model.viewState == .error(errorMessage: ChangeTierError.somethingWentWrong.localizedDescription)
                )
            }

            await expectServiceAndViewModelReleased()
        }
    }
}
