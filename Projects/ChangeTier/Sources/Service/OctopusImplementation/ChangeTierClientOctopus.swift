import Foundation
import hCoreUI
import hGraphQL
import hCore

public class ChangeTierClientOctopus: ChangeTierClient {
    @Inject var octopus: hOctopus
    
    public init() {}

    public func getTier(contractId: String, tierSource: ChangeTierSource) async throws(ChangeTierError) -> ChangeTierIntentModel {
        
        let source: OctopusGraphQL.ChangeTierDeductibleSource = {
            switch tierSource {
            case .changeTier: return .selfService
            case .betterCoverage: return .terminationBetterCoverage
            case .betterPrice: return .terminationBetterPrice
            }
        }()
        
        let input: OctopusGraphQL.ChangeTierDeductibleCreateIntentInput = .init(contractId: contractId, source: .case(source))
        let mutation = OctopusGraphQL.ChangeTierDeductibleCreateIntentMutation(input: input)
        
        do {
            let data = try await octopus.client.perform(mutation: mutation)
            let intent = data.changeTierDeductibleCreateIntent.intent
            
            // list of all unique tierNames
            var uniqueTierNames: [String] = []
            
            let FAQs: [FAQ] = [
                .init(title: "question 1", description: "..."),
                .init(title: "question 2", description: "..."),
                .init(title: "question 3", description: "..."),
            ]
            
            intent?.quotes.forEach({ tier in
                let tierNameIsNotInList = uniqueTierNames.first(where: { $0 == (tier.tierName ?? "") })?.isEmpty
                if let tierName = tier.tierName, tierNameIsNotInList ?? false {
                    uniqueTierNames.append(tierName)
                }
            })
            
            var allTiers: [Tier] = []
            
            
            /* fetch from contract **/
            let contractsQuery = OctopusGraphQL.ContractsQuery()
            let contractData = try await octopus.client.fetch(query: contractsQuery, cachePolicy: .fetchIgnoringCacheCompletely)
            
            let currentContract = contractData.currentMember.activeContracts.first(where: { $0.id == contractId })
            
            let deductible = currentContract?.currentAgreement.deductible
            let currentDeductible: Deductible? = {
                if let currentContract, let deductible = deductible {
                    return Deductible(
                        deductibleAmount: .init(fragment: deductible.amount.fragments.moneyFragment),
                        deductiblePercentage: deductible.percentage,
                        subTitle: deductible.displayText,
                        premium: .init(fragment: currentContract.currentAgreement.premium.fragments.moneyFragment)
                    )
                }
                return nil
            }()
            
            
            /* filter tiers and deductibles*/
            uniqueTierNames.forEach({ tierName in
                let allQuotesWithNameX = intent?.quotes.filter({ $0.tierName == tierName })
                
                let allDeductiblesForX: [Deductible] = allQuotesWithNameX?.map({ quote in
                        return .init(
                            deductibleAmount: .init(optionalFragment: quote.deductible?.amount.fragments.moneyFragment),
                            deductiblePercentage: quote.deductible?.percentage,
                            subTitle: quote.deductible?.displayText,
                            premium: .init(optionalFragment: allQuotesWithNameX?.first?.premium.fragments.moneyFragment)
                        )
                }) ?? []
                
                let displayItems: [Tier.TierDisplayItem] = allQuotesWithNameX?.first?.displayItems.map({ .init(title: $0.displayTitle, subTitle: $0.displaySubtitle, value: $0.displayValue)}) ?? []
                
                allTiers.append(
                    .init(
                        id: allQuotesWithNameX?.first?.id ?? "",
                        name: allQuotesWithNameX?.first?.tierName ?? "",
                        level: allQuotesWithNameX?.first?.tierLevel ?? 0,
                        deductibles: allDeductiblesForX,
                        premium: .init(optionalFragment: allQuotesWithNameX?.first?.premium.fragments.moneyFragment) ?? .init(amount: "0", currency: "SEK"),
                        displayItems: displayItems,
                        exposureName: currentContract?.exposureDisplayName,
                        productVariant: .init(data: allQuotesWithNameX?.first?.productVariant.fragments.productVariantFragment),
                        FAQs: FAQs)
                )
            })

            let intentModel: ChangeTierIntentModel = .init(
                id: "",
                activationDate: intent?.activationDate.localDateToDate ?? Date(),
                tiers: allTiers,
                currentPremium: .init(
                    amount: String(currentContract?.currentAgreement.premium.amount ?? 0),
                    currency: currentContract?.currentAgreement.premium.currencyCode.rawValue ?? ""),
                currentTier: nil, /* TODO */
                currentDeductible: currentDeductible,
                canEditTier: currentContract?.supportsChangeTier ?? false
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
}
