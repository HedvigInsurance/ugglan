import Foundation
import hCore
import hCoreUI
import hGraphQL

public class ChangeTierClientOctopus: ChangeTierClient {
    @Inject var octopus: hOctopus

    public init() {}

    public func getTier(input: ChangeTierInputData) async throws -> ChangeTierIntentModel {

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
            async let createIntentdata = try octopus.client.perform(mutation: mutation)

            let contractsQuery = OctopusGraphQL.ContractQuery(contractId: input.contractId)
            async let contractData = try octopus.client.fetch(
                query: contractsQuery,
                cachePolicy: .fetchIgnoringCacheCompletely
            )

            let data = try await [createIntentdata, contractData] as [Any]
            let createIntentResponse = data[0] as! OctopusGraphQL.ChangeTierDeductibleCreateIntentMutation.Data
            let contractResponse = data[1] as! OctopusGraphQL.ContractQuery.Data

            if let error = createIntentResponse.changeTierDeductibleCreateIntent.userError, let message = error.message
            {
                throw ChangeTierError.errorMessage(message: message)
            }
            guard let intent = createIntentResponse.changeTierDeductibleCreateIntent.intent else {
                throw ChangeTierError.somethingWentWrong
            }
            let currentContract = contractResponse.contract

            /* get filtered tiers  */
            let filteredTiers = getFilteredTiers(currentContract: currentContract, intent: intent)

            /* get current tier if any matching */
            let currentTier: Tier? = filteredTiers.first(where: {
                $0.name == intent.currentTierName && $0.level == intent.currentTierLevel
            })

            /* get current deductible if any matching */
            let deductible = currentContract.currentAgreement.deductible
            let currentDeductible: Quote? = {
                if let deductible = deductible {
                    return Quote(
                        id: "current",
                        deductibleAmount: .init(fragment: deductible.amount.fragments.moneyFragment),
                        deductiblePercentage: (deductible.percentage == 0) ? nil : deductible.percentage,
                        subTitle: (deductible.displayText == "") ? nil : deductible.displayText,
                        premium: .init(fragment: currentContract.currentAgreement.premium.fragments.moneyFragment),
                        displayItems: currentTier?.deductibles.first?.displayItems ?? [],
                        productVariant: currentTier?.deductibles.first?.productVariant
                    )
                }
                return nil
            }()

            let intentModel: ChangeTierIntentModel = .init(
                displayName: (currentDeductible?.productVariant?.displayName
                    ?? intent.quotes.first?.productVariant.displayName) ?? "",
                activationDate: intent.activationDate.localDateToDate ?? Date(),
                tiers: filteredTiers,
                currentPremium: .init(
                    amount: String(currentContract.currentAgreement.premium.amount),
                    currency: currentContract.currentAgreement.premium.currencyCode.rawValue
                ),
                currentTier: currentTier,
                currentDeductible: currentDeductible,
                selectedTier: nil,
                selectedDeductible: nil,
                canEditTier: currentContract.supportsChangeTier,
                typeOfContract:
                    TypeOfContract.resolve(for: currentContract.currentAgreement.productVariant.typeOfContract)
            )
            if intentModel.tiers.isEmpty {
                throw ChangeTierError.emptyList
            }

            return intentModel

        } catch let ex {
            throw ChangeTierError.somethingWentWrong
        }
    }

    public func commitTier(quoteId: String) async throws {
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
        currentContract: OctopusGraphQL.ContractQuery.Data.Contract,
        intent: OctopusGraphQL.ChangeTierDeductibleCreateIntentMutation.Data.ChangeTierDeductibleCreateIntent.Intent
    ) -> [Tier] {
        // list of all unique tierNames
        var allTiers: [Tier] = []

        var uniqueTierNames: [String] = []
        intent.quotes
            .forEach({ tier in
                let tierNameIsNotInList = uniqueTierNames.first(where: { $0 == (tier.tierName ?? "") })?.isEmpty
                if let tierName = tier.tierName, tierNameIsNotInList ?? true {
                    uniqueTierNames.append(tierName)
                }
            })

        /* filter tiers and deductibles*/
        uniqueTierNames.forEach({ tierName in
            let allQuotesWithNameX = intent.quotes.filter({ $0.tierName == tierName })
            var allDeductiblesForX: [Quote] = []

            allQuotesWithNameX
                .forEach({ quote in
                    if let deductableAmount = quote.deductible?.amount {
                        let deductible = Quote(
                            id: quote.id,
                            deductibleAmount: .init(fragment: deductableAmount.fragments.moneyFragment),
                            deductiblePercentage: (quote.deductible?.percentage == 0)
                                ? nil : quote.deductible?.percentage,
                            subTitle: (quote.deductible?.displayText == "") ? nil : quote.deductible?.displayText,
                            premium: .init(fragment: quote.premium.fragments.moneyFragment),
                            displayItems: quote.displayItems.map({
                                .init(
                                    title: $0.displayTitle,
                                    subTitle: $0.displayValue == "" ? nil : $0.displaySubtitle,
                                    value: $0.displayValue
                                )
                            }),
                            productVariant: .init(data: quote.productVariant.fragments.productVariantFragment)
                        )
                        allDeductiblesForX.append(deductible)
                    }
                })

            allTiers.append(
                .init(
                    id: allQuotesWithNameX.first?.id ?? "",
                    name: allQuotesWithNameX.first?.productVariant.displayNameTier ?? "",
                    level: allQuotesWithNameX.first?.tierLevel ?? 0,
                    deductibles: allDeductiblesForX,
                    exposureName: currentContract.exposureDisplayName
                )
            )
        })
        return allTiers
    }
}
