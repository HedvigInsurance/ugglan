import Foundation
import hCore
import hCoreUI
import hGraphQL

public class ChangeTierClientOctopus: ChangeTierClient {
    @Inject var octopus: hOctopus

    public init() {}

    public func getTier(
        contractId: String,
        tierSource: ChangeTierSource
    ) async throws(ChangeTierError) -> ChangeTierIntentModel {

        let source: OctopusGraphQL.ChangeTierDeductibleSource = {
            switch tierSource {
            case .changeTier: return .selfService
            case .betterCoverage: return .terminationBetterCoverage
            case .betterPrice: return .terminationBetterPrice
            }
        }()

        do {
            let input: OctopusGraphQL.ChangeTierDeductibleCreateIntentInput = .init(
                contractId: contractId,
                source: .case(source)
            )
            let mutation = OctopusGraphQL.ChangeTierDeductibleCreateIntentMutation(input: input)
            async let createIntentdata = try octopus.client.perform(mutation: mutation)

            let contractsQuery = OctopusGraphQL.ContractQuery(contractId: contractId)
            async let contractData = try octopus.client.fetch(
                query: contractsQuery,
                cachePolicy: .fetchIgnoringCacheCompletely
            )

            let data = try await [createIntentdata, contractData] as [Any]
            let createIntentResponse = data[0] as! OctopusGraphQL.ChangeTierDeductibleCreateIntentMutation.Data
            let contractResponse = data[1] as! OctopusGraphQL.ContractQuery.Data

            let intent = createIntentResponse.changeTierDeductibleCreateIntent.intent
            let currentContract = contractResponse.contract

            /* get current deductible */
            let deductible = currentContract.currentAgreement.deductible
            let currentDeductible: Deductible? = {
                if let deductible = deductible {
                    return Deductible(
                        deductibleAmount: .init(fragment: deductible.amount.fragments.moneyFragment),
                        deductiblePercentage: deductible.percentage,
                        subTitle: deductible.displayText,
                        premium: .init(fragment: currentContract.currentAgreement.premium.fragments.moneyFragment)
                    )
                }
                return nil
            }()

            let filteredTiers = getFilteredTiers(currentContract: currentContract, intent: intent)

            /* map currentTier with existing */
            let currentTier: Tier? = filteredTiers.first(where: {
                $0.name == intent?.currentTierName && $0.level == intent?.currentTierLevel
            })

            let intentModel: ChangeTierIntentModel = .init(
                activationDate: intent?.activationDate.localDateToDate ?? Date(),
                tiers: filteredTiers,
                currentPremium: .init(
                    amount: String(currentContract.currentAgreement.premium.amount),
                    currency: currentContract.currentAgreement.premium.currencyCode.rawValue
                ),
                currentTier: currentTier,
                currentDeductible: currentDeductible,
                canEditTier: currentContract.supportsChangeTier
            )

            return intentModel

        } catch {
            throw ChangeTierError.somethingWentWrong
        }
    }

    public func commitTier(quoteId: String) async throws(ChangeTierError) {
        let input = OctopusGraphQL.ChangeTierDeductibleCommitIntentInput(quoteId: quoteId)
        let mutation = OctopusGraphQL.ChangeTierDeductibleCommitIntentMutation(input: input)

        do {
            let data = try await octopus.client.perform(mutation: mutation)
            if let userError = data.changeTierDeductibleCommitIntent.userError?.message {
                throw ChangeTierError.errorMessage(message: userError)
            }
        } catch {
            throw ChangeTierError.somethingWentWrong
        }
    }

    func getFilteredTiers(
        currentContract: OctopusGraphQL.ContractQuery.Data.Contract?,
        intent: OctopusGraphQL.ChangeTierDeductibleCreateIntentMutation.Data.ChangeTierDeductibleCreateIntent.Intent?
    ) -> [Tier] {
        // list of all unique tierNames
        var allTiers: [Tier] = []

        var uniqueTierNames: [String] = []
        intent?.quotes
            .forEach({ tier in
                let tierNameIsNotInList = uniqueTierNames.first(where: { $0 == (tier.tierName ?? "") })?.isEmpty
                if let tierName = tier.tierName, tierNameIsNotInList ?? true {
                    uniqueTierNames.append(tierName)
                }
            })

        /* filter tiers and deductibles*/
        uniqueTierNames.forEach({ tierName in
            let allQuotesWithNameX = intent?.quotes.filter({ $0.tierName == tierName })
            var allDeductiblesForX: [Deductible] = []

            allQuotesWithNameX?
                .forEach({ quote in
                    if let deductableAmount = quote.deductible?.amount {
                        let deductible = Deductible(
                            deductibleAmount: .init(fragment: deductableAmount.fragments.moneyFragment),
                            deductiblePercentage: quote.deductible?.percentage,
                            subTitle: quote.deductible?.displayText,
                            premium: .init(optionalFragment: allQuotesWithNameX?.first?.premium.fragments.moneyFragment)
                        )
                        allDeductiblesForX.append(deductible)
                    }
                })

            var displayItems: [Tier.TierDisplayItem] = []
            allQuotesWithNameX?
                .forEach({
                    displayItems.append(
                        contentsOf: $0.displayItems.map({
                            Tier.TierDisplayItem(
                                title: $0.displayTitle,
                                subTitle: $0.displaySubtitle,
                                value: $0.displayValue
                            )
                        })
                    )
                })

            let FAQs: [FAQ] = [
                .init(title: "question 1", description: "..."),
                .init(title: "question 2", description: "..."),
                .init(title: "question 3", description: "..."),
            ]

            allTiers.append(
                .init(
                    id: allQuotesWithNameX?.first?.id ?? "",
                    name: allQuotesWithNameX?.first?.tierName ?? "",
                    level: allQuotesWithNameX?.first?.tierLevel ?? 0,
                    deductibles: allDeductiblesForX,
                    premium: .init(optionalFragment: allQuotesWithNameX?.first?.premium.fragments.moneyFragment)
                        ?? .init(amount: "0", currency: "SEK"),
                    displayItems: displayItems,
                    exposureName: currentContract?.exposureDisplayName,
                    productVariant: .init(
                        data: allQuotesWithNameX?.first?.productVariant.fragments.productVariantFragment
                    ),
                    FAQs: FAQs
                )
            )
        })
        return allTiers
    }
}
