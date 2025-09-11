import ChangeTier
import Foundation
import hCore
import hCoreUI
import hGraphQL

class ChangeTierClientOctopus: ChangeTierClient {
    @Inject @preconcurrency var octopus: hOctopus

    func getTier(input: ChangeTierInputData) async throws -> ChangeTierIntentModel {
        let source: OctopusGraphQL.ChangeTierDeductibleSource = {
            switch input.source {
            case .changeTier: return .selfService
            case .betterCoverage: return .terminationBetterCoverage
            case .betterPrice: return .terminationBetterPrice
            }
        }()

        do {
            let input: OctopusGraphQL.ChangeTierDeductibleCreateIntentInput = .init(
                contractId: input.contractId,
                source: .case(source)
            )
            let mutation = OctopusGraphQL.ChangeTierDeductibleCreateIntentMutation(input: input)
            let createIntentResponse = try await octopus.client.perform(mutation: mutation)
            let contractsQuery = OctopusGraphQL.ContractQuery(contractId: input.contractId)

            let contractResponse = try await octopus.client.fetch(
                query: contractsQuery,
                cachePolicy: .fetchIgnoringCacheCompletely
            )

            if let error = createIntentResponse.changeTierDeductibleCreateIntent.userError, let message = error.message
            {
                throw ChangeTierError.errorMessage(message: message)
            }
            guard let intent = createIntentResponse.changeTierDeductibleCreateIntent.intent else {
                throw ChangeTierError.somethingWentWrong
            }
            let currentContract = contractResponse.contract
            let agreementToChange = intent.agreementToChange
            let filteredTiers = getFilteredTiers(currentContract: currentContract, intent: intent)
            let currentTier: Tier = getCurrentTier(
                filteredTiers: filteredTiers,
                currentContract: currentContract,
                intent: intent
            )
            let currentDeductible = getCurrentDeductible(agreementToChange: agreementToChange, currentTier: currentTier)

            let intentModel: ChangeTierIntentModel = .init(
                displayName: (currentDeductible?.productVariant?.displayName
                    ?? intent.quotes.first?.productVariant.displayName) ?? "",
                activationDate: intent.activationDate.localDateToDate ?? Date(),
                tiers: filteredTiers,
                currentPremium: .init(
                    amount: String(agreementToChange.basePremium.amount),
                    currency: agreementToChange.basePremium.currencyCode.rawValue
                ),
                currentTier: currentTier,
                currentQuote: currentDeductible,
                selectedTier: nil,
                selectedQuote: nil,
                canEditTier: currentContract.supportsChangeTier,
                typeOfContract:
                    TypeOfContract.resolve(for: agreementToChange.productVariant.typeOfContract)
            )
            if intentModel.tiers.isEmpty {
                throw ChangeTierError.emptyList
            }

            return intentModel
        } catch let ex {
            if let ex = ex as? ChangeTierError {
                throw ex
            }
            throw ChangeTierError.somethingWentWrong
        }
    }

    func commitTier(quoteId: String) async throws {
        let input = OctopusGraphQL.ChangeTierDeductibleCommitIntentInput(quoteId: quoteId)
        let mutation = OctopusGraphQL.ChangeTierDeductibleCommitIntentMutation(input: input)

        do {
            let delayTask = Task {
                try await Task.sleep(nanoseconds: 3_000_000_000)
            }
            let data = try await octopus.client.perform(mutation: mutation)

            try await delayTask.value

            if let userError = data.changeTierDeductibleCommitIntent.userError?.message {
                throw ChangeTierError.errorMessage(message: userError)
            }
        } catch {
            throw ChangeTierError.somethingWentWrong
        }
    }

    func getFilteredTiers(
        currentContract: OctopusGraphQL.ContractQuery.Data.Contract,
        intent: OctopusGraphQL.ChangeTierDeductibleCreateIntentMutation.Data.ChangeTierDeductibleCreateIntent.Intent
    ) -> [Tier] {
        // list of all unique tierNames
        var allTiers: [Tier] = []

        var uniqueTierNames: [String] = []
        for tier in intent.quotes {
            let tierNameIsNotInList = uniqueTierNames.first(where: { $0 == (tier.tierName ?? "") })?.isEmpty
            if let tierName = tier.tierName, tierNameIsNotInList ?? true {
                uniqueTierNames.append(tierName)
            }
        }

        /* filter tiers and deductibles*/
        for tierName in uniqueTierNames {
            let allQuotesWithNameX = intent.quotes.filter { $0.tierName == tierName }
            var allDeductiblesForX: [Quote] = []

            for quote in allQuotesWithNameX {
                let deductible = Quote(
                    id: quote.id,
                    quoteAmount: .init(optionalFragment: quote.deductible?.amount.fragments.moneyFragment),
                    quotePercentage: (quote.deductible?.percentage == 0)
                        ? nil : quote.deductible?.percentage,
                    subTitle: (quote.deductible?.displayText == "") ? nil : quote.deductible?.displayText,
                    basePremium: .init(fragment: quote.premium.fragments.moneyFragment),
                    displayItems: quote.displayItems.map {
                        .init(
                            title: $0.displayTitle,
                            subTitle: $0.displayValue == "" ? nil : $0.displaySubtitle,
                            value: $0.displayValue
                        )
                    },
                    productVariant: .init(data: quote.productVariant.fragments.productVariantFragment),
                    addons: quote.addons.compactMap { .init(with: $0) }
                )
                allDeductiblesForX.append(deductible)
            }

            allTiers.append(
                .init(
                    id: tierName,
                    name: allQuotesWithNameX.first?.productVariant.displayNameTier ?? "",
                    level: allQuotesWithNameX.first?.tierLevel ?? 0,
                    quotes: allDeductiblesForX,
                    exposureName: currentContract.exposureDisplayName
                )
            )
        }
        return allTiers
    }

    private func getCurrentTier(
        filteredTiers: [Tier],
        currentContract: OctopusGraphQL.ContractQuery.Data.Contract,
        intent: OctopusGraphQL.ChangeTierDeductibleCreateIntentMutation.Data.ChangeTierDeductibleCreateIntent.Intent
    ) -> Tier {
        filteredTiers.first(where: {
            $0.name.lowercased() == intent.agreementToChange.tierName?.lowercased()
        })
            ?? Tier(
                id: intent.agreementToChange.tierName ?? "",
                name: intent.agreementToChange.productVariant.displayNameTier ?? "",
                level: intent.agreementToChange.tierLevel ?? 0,
                quotes: [
                    .init(
                        id: "currentTier",
                        quoteAmount: .init(
                            optionalFragment: intent.agreementToChange.deductible?.amount.fragments.moneyFragment
                        ),
                        quotePercentage: (intent.agreementToChange.deductible?.percentage == 0)
                            ? nil : intent.agreementToChange.deductible?.percentage,
                        subTitle: nil,
                        basePremium: .init(fragment: intent.agreementToChange.basePremium.fragments.moneyFragment),
                        displayItems: [],
                        productVariant: .init(
                            data: intent.agreementToChange.productVariant.fragments.productVariantFragment
                        ),
                        addons: []
                    )
                ],
                exposureName: currentContract.exposureDisplayName
            )
    }

    private func getCurrentDeductible(
        agreementToChange: OctopusGraphQL.ChangeTierDeductibleCreateIntentMutation.Data.ChangeTierDeductibleCreateIntent
            .Intent.AgreementToChange,
        currentTier: Tier
    ) -> Quote? {
        let deductible = agreementToChange.deductible
        let currentDeductible: Quote? = {
            if let deductible {
                return Quote(
                    id: "current",
                    quoteAmount: .init(fragment: deductible.amount.fragments.moneyFragment),
                    quotePercentage: (deductible.percentage == 0) ? nil : deductible.percentage,
                    subTitle: (deductible.displayText == "") ? nil : deductible.displayText,
                    basePremium: .init(fragment: agreementToChange.basePremium.fragments.moneyFragment),
                    displayItems: currentTier.quotes.first?.displayItems ?? [],
                    productVariant: currentTier.quotes.first?.productVariant,
                    addons: []
                )
            }
            return nil
        }()
        return currentDeductible
    }

    func compareProductVariants(termsVersion: [String]) async throws -> ProductVariantComparison {
        do {
            let productVariantQuery = OctopusGraphQL.ProductVariantComparisonQuery(termsVersions: termsVersion)
            let productVariantData = try await octopus.client.fetch(
                query: productVariantQuery,
                cachePolicy: .fetchIgnoringCacheCompletely
            )

            let productVariantRows: [ProductVariantComparison.ProductVariantComparisonRow] =
                productVariantData.productVariantComparison.rows.map {
                    .init(data: $0.fragments.productVariantComparisonRowFragment)
                }

            let productVariantColumns: [ProductVariant] = productVariantData.productVariantComparison
                .variantColumns.map { .init(data: $0.fragments.productVariantFragment) }

            let productVariantComparision = ProductVariantComparison(
                rows: productVariantRows,
                variantColumns: productVariantColumns
            )

            return productVariantComparision
        } catch _ {
            throw ChangeTierError.somethingWentWrong
        }
    }
}

extension ProductVariantComparison.ProductVariantComparisonRow {
    init(
        data: OctopusGraphQL.ProductVariantComparisonRowFragment
    ) {
        self.init(
            title: data.title,
            description: data.description,
            colorCode: data.colorCode,
            cells: data.cells.map { .init(isCovered: $0.isCovered, coverageText: $0.coverageText) }
        )
    }
}

extension Quote.Addon {
    init(
        with data: OctopusGraphQL.ChangeTierDeductibleCreateIntentMutation.Data.ChangeTierDeductibleCreateIntent.Intent
            .Quote.Addon
    ) {
        self.init(
            addonId: data.addonId,
            addonVariant: .init(fragment: data.addonVariant.fragments.addonVariantFragment),
            displayItems: data.displayItems.map { Quote.DisplayItem(with: $0) },
            displayName: data.displayName,
            premium: .init(fragment: data.premium.fragments.moneyFragment),
            previousPremium: .init(fragment: data.previousPremium.fragments.moneyFragment)
        )
    }
}

extension Quote.DisplayItem {
    init(
        with data: OctopusGraphQL.ChangeTierDeductibleCreateIntentMutation.Data.ChangeTierDeductibleCreateIntent.Intent
            .Quote.Addon.DisplayItem
    ) {
        self.init(
            title: data.displayTitle,
            subTitle: data.displaySubtitle,
            value: data.displayValue
        )
    }
}
