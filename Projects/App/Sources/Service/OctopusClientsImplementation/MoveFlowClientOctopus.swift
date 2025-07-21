import ChangeTier
import Foundation
import MoveFlow
import hCore
import hCoreUI
import hGraphQL

public class MoveFlowClientOctopus: MoveFlowClient {
    @Inject var octopus: hOctopus

    public init() {}

    public func sendMoveIntent() async throws -> MoveConfigurationModel {
        let mutation = OctopusGraphQL.MoveIntentCreateMutation()
        let data = try await octopus.client.perform(mutation: mutation)

        if let moveIntentFragment = data.moveIntentCreate.moveIntent?.fragments.moveIntentFragment {
            return MoveConfigurationModel(from: moveIntentFragment)
        } else if let userError = data.moveIntentCreate.userError?.message {
            throw MovingFlowError.serverError(message: userError)
        }
        throw MovingFlowError.missingDataError(message: L10n.General.errorBody)
    }

    public func requestMoveIntent(input: RequestMoveIntentInput) async throws -> MoveQuotesModel {
        let moveIntentRequestInput = OctopusGraphQL.MoveIntentRequestInput(
            moveToAddress: .init(
                street: input.addressInputModel.address,
                postalCode: input.addressInputModel.postalCode.replacingOccurrences(of: " ", with: "")
            ),
            moveFromAddressId: input.selectedAddressId,
            movingDate: input.addressInputModel.accessDate?.localDateString ?? "",
            numberCoInsured: input.addressInputModel.nbOfCoInsured,
            squareMeters: Int(input.addressInputModel.squareArea) ?? 0,
            apartment: GraphQLNullable(optionalValue: apartmentInput(addressInputModel: input.addressInputModel)),
            house: GraphQLNullable(
                optionalValue: houseInput(
                    selectedHousingType: input.addressInputModel.selectedHousingType,
                    houseInformationInputModel: input.houseInformationInputModel
                )
            )
        )

        let mutation = OctopusGraphQL.MoveIntentRequestMutation(
            intentId: input.intentId,
            input: moveIntentRequestInput
        )

        let data = try await octopus.client.perform(mutation: mutation)
        if let moveIntentFragment = data.moveIntentRequest.moveIntent?.fragments.moveIntentFragment {
            return MoveQuotesModel(from: moveIntentFragment)
        } else if let userError = data.moveIntentRequest.userError?.message {
            throw MovingFlowError.serverError(message: userError)
        }
        throw MovingFlowError.missingDataError(message: L10n.General.errorBody)
    }

    public func confirmMoveIntent(intentId: String, currentHomeQuoteId: String, removedAddons: [String]) async throws {
        let mutation = OctopusGraphQL.MoveIntentCommitMutation(
            intentId: intentId,
            homeQuoteId: GraphQLNullable.init(optionalValue: currentHomeQuoteId),
            removedAddons: GraphQLNullable.init(optionalValue: removedAddons)
        )
        let delayTask = Task {
            try await Task.sleep(nanoseconds: 3_000_000_000)
        }
        let data = try await octopus.client.perform(mutation: mutation)

        try await delayTask.value

        if let userError = data.moveIntentCommit.userError {
            throw MovingFlowError.serverError(message: userError.message ?? "")
        }
    }

    private func apartmentInput(addressInputModel: AddressInputModel) -> OctopusGraphQL.MoveToApartmentInput? {
        switch addressInputModel.selectedHousingType {
        case .apartment, .rental:
            return OctopusGraphQL.MoveToApartmentInput(
                subType: addressInputModel.selectedHousingType.asMoveApartmentSubType,
                isStudent: addressInputModel.isStudent
            )
        case .house:
            return nil
        }
    }

    private func houseInput(
        selectedHousingType: HousingType,
        houseInformationInputModel: HouseInformationInputModel?
    ) -> OctopusGraphQL.MoveToHouseInput? {
        switch selectedHousingType {
        case .apartment, .rental:
            return nil
        case .house:
            guard let houseInformationInputModel = houseInformationInputModel else { return nil }
            return OctopusGraphQL.MoveToHouseInput(
                ancillaryArea: Int(houseInformationInputModel.ancillaryArea) ?? 0,
                yearOfConstruction: Int(houseInformationInputModel.yearOfConstruction) ?? 0,
                numberOfBathrooms: houseInformationInputModel.bathrooms,
                isSubleted: houseInformationInputModel.isSubleted,
                extraBuildings: houseInformationInputModel.extraBuildings.map({
                    OctopusGraphQL.MoveExtraBuildingInput(
                        area: $0.livingArea,
                        type: GraphQLEnum<OctopusGraphQL.MoveExtraBuildingType>(rawValue: $0.type),
                        hasWaterConnected: $0.connectedToWater
                    )
                })

            )
        }
    }
}

@MainActor
extension MoveConfigurationModel {
    init(from data: OctopusGraphQL.MoveIntentFragment) {
        self.init(
            id: data.id,
            currentHomeAddresses: data.currentHomeAddresses.compactMap({
                MoveAddress(from: $0.fragments.moveAddressFragment)
            }),
            extraBuildingTypes: data.extraBuildingTypes.compactMap({ $0.rawValue }),
            isApartmentAvailableforStudent: data.isApartmentAvailableforStudent ?? false,
            maxApartmentNumberCoInsured: data.maxApartmentNumberCoInsured,
            maxApartmentSquareMeters: data.maxApartmentSquareMeters,
            maxHouseNumberCoInsured: data.maxHouseNumberCoInsured,
            maxHouseSquareMeters: data.maxHouseSquareMeters
        )
    }
}

@MainActor
extension MoveQuotesModel {
    init(from data: OctopusGraphQL.MoveIntentFragment) {
        self.init(
            homeQuotes: data.homeQuotes?.compactMap({ MovingFlowQuote(from: $0) }) ?? [],
            mtaQuotes: data.fragments.quoteFragment.mtaQuotes?.compactMap({ MovingFlowQuote(from: $0) }) ?? [],
            changeTierModel: {
                if let data = data.fragments.quoteFragment.homeQuotes, !data.isEmpty {
                    return ChangeTierIntentModel.initWith(data: data)
                }
                return nil
            }()
        )
    }
}

@MainActor
extension MoveAddress {
    init(from data: OctopusGraphQL.MoveAddressFragment) {
        let minMovingDate = data.minMovingDate
        let maxMovingDate = data.maxMovingDate
        let minMovingDateDate = minMovingDate.localDateToDate
        let maxMovingDateDate = maxMovingDate.localDateToDate
        let minMaxMovingDate: (min: String, max: String) = {
            if let minMovingDateDate, let maxMovingDateDate {
                if minMovingDateDate < maxMovingDateDate {
                    return (minMovingDate, maxMovingDate)
                } else {
                    return (maxMovingDate, minMovingDate)

                }
            } else {
                return (data.minMovingDate, data.maxMovingDate)
            }
        }()

        self.init(
            id: data.id,
            displayTitle: data.displayTitle,
            displaySubtitle: data.displaySubtitle,
            maxMovingDate: minMaxMovingDate.max,
            minMovingDate: minMaxMovingDate.min,
            suggestedNumberCoInsured: data.suggestedNumberCoInsured
        )
    }
}

@MainActor
extension MovingFlowQuote {
    init(from data: OctopusGraphQL.QuoteFragment.MtaQuote) {
        let productVariantFragment = data.productVariant.fragments.productVariantFragment
        self.init(
            premium: .init(fragment: data.premium.fragments.moneyFragment),
            startDate: data.startDate.localDateToDate?.displayDateDDMMMYYYYFormat ?? data.startDate,
            displayName: productVariantFragment.displayName,
            insurableLimits: productVariantFragment.insurableLimits.compactMap({
                .init(label: $0.label, limit: $0.limit, description: $0.description)
            }),
            perils: productVariantFragment.perils.compactMap({ .init(fragment: $0.fragments.perilFragment) }),
            documents: productVariantFragment.documents.compactMap({ .init($0) }),
            contractType: TypeOfContract.resolve(for: data.productVariant.typeOfContract),
            id: UUID().uuidString,
            displayItems: data.displayItems.map({ .init($0.fragments.moveQuoteDisplayItemFragment) }),
            exposureName: data.exposureName,
            addons: data.addons.map({ AddonDataModel(fragment: $0.fragments.moveAddonQuoteFragment) }),
            discountDisplayItems: []
        )
    }

    init(from data: OctopusGraphQL.QuoteFragment.HomeQuote) {
        let productVariantFragment = data.productVariant.fragments.productVariantFragment
        self.init(
            premium: .init(fragment: data.premium.fragments.moneyFragment),
            startDate: data.startDate.localDateToDate?.displayDateDDMMMYYYYFormat ?? data.startDate,
            displayName: productVariantFragment.displayName,
            insurableLimits: productVariantFragment.insurableLimits.compactMap({
                .init(label: $0.label, limit: $0.limit, description: $0.description)
            }),
            perils: productVariantFragment.perils.compactMap({ .init(fragment: $0.fragments.perilFragment) }),
            documents: productVariantFragment.documents.compactMap({ .init($0) }),
            contractType: TypeOfContract.resolve(for: data.productVariant.typeOfContract),
            id: data.id,
            displayItems: data.displayItems.map({ .init($0.fragments.moveQuoteDisplayItemFragment) }),
            exposureName: data.exposureName,
            addons: data.addons.map({ AddonDataModel(fragment: $0.fragments.moveAddonQuoteFragment) }),
            discountDisplayItems: [],
        )
    }
}

extension InsuranceDocument {
    init(_ data: OctopusGraphQL.ProductVariantFragment.Document) {
        self.init(
            displayName: data.displayName,
            url: data.url
        )
    }
}

extension DisplayItem {
    init(_ data: OctopusGraphQL.MoveQuoteDisplayItemFragment) {
        self.init(
            displaySubtitle: data.displaySubtitle,
            displayTitle: data.displayTitle,
            displayValue: data.displayValue
        )
    }
}

@MainActor
extension ChangeTierIntentModel {
    static func initWith(data: [OctopusGraphQL.QuoteFragment.HomeQuote]) -> ChangeTierIntentModel {
        let groupedQuotes = data.reduce([(tierName: String, quotes: [OctopusGraphQL.QuoteFragment.HomeQuote])]()) {
            partialResult,
            data in
            var result = partialResult
            if let existingIndex = partialResult.firstIndex(where: { $0.tierName == data.tierName }) {
                let existingValue = partialResult[existingIndex]
                var existingQuotes = existingValue.quotes
                existingQuotes.append(data)
                result[existingIndex] = (existingValue.tierName, existingQuotes)
            } else {
                result.append((data.tierName, [data]))
            }
            return result
        }

        let tiers = groupedQuotes.compactMap { (_, quotes) in
            if let firstQuote = quotes.first {
                let quotes = quotes.compactMap { quote in
                    return Quote(
                        id: quote.id,
                        quoteAmount: .init(optionalFragment: quote.deductible?.amount.fragments.moneyFragment),
                        quotePercentage: (quote.deductible?.percentage == 0) ? nil : quote.deductible?.percentage,
                        subTitle: quote.deductible?.displayText,
                        basePremium: .init(fragment: quote.premium.fragments.moneyFragment),
                        displayItems: [],
                        productVariant: ProductVariant(
                            data: firstQuote.productVariant.fragments.productVariantFragment
                        ),
                        addons: []
                    )
                }
                let tier = Tier(
                    id: firstQuote.tierName,
                    name: firstQuote.productVariant.displayNameTier ?? firstQuote.tierName,
                    level: firstQuote.tierLevel,
                    quotes: quotes,
                    exposureName: firstQuote.exposureName
                )
                return tier
            }
            return nil
        }

        let currentTierAndQuote: (tier: Tier?, deductible: Quote?) = {
            if let defaultChoise = data.first(where: { $0.defaultChoice }),
                let currentTier = tiers.first(where: { $0.id == defaultChoise.tierName }),
                let currentQuote = currentTier.quotes.first(where: { $0.id == defaultChoise.id })
            {
                return (currentTier, currentQuote)
            }
            return (nil, nil)
        }()
        let intentModel: ChangeTierIntentModel = .init(
            displayName: currentTierAndQuote.deductible?.productVariant?.displayName ?? tiers.first?.quotes
                .first?
                .productVariant?
                .displayName ?? "",
            activationDate: data.first?.startDate.localDateToDate ?? Date(),
            tiers: tiers,
            currentPremium: nil,
            currentTier: nil,
            currentQuote: nil,
            selectedTier: currentTierAndQuote.tier,
            selectedQuote: currentTierAndQuote.deductible,
            canEditTier: true,
            typeOfContract: TypeOfContract.resolve(for: data.first?.productVariant.typeOfContract ?? "")
        )
        return intentModel
    }

}

@MainActor
extension AddonDataModel {
    init(fragment: OctopusGraphQL.MoveAddonQuoteFragment) {
        self.init(
            id: fragment.addonId,
            quoteInfo: .init(title: fragment.displayName, description: L10n.movingFlowTravelAddonSummaryDescription),
            displayItems: fragment.displayItems.map({
                .init(displaySubtitle: $0.displaySubtitle, displayTitle: $0.displayTitle, displayValue: $0.displayValue)
            }),
            coverageDisplayName: fragment.coverageDisplayName,
            price: .init(fragment: fragment.premium.fragments.moneyFragment),
            addonVariant: .init(fragment: fragment.addonVariant.fragments.addonVariantFragment),
            startDate: fragment.startDate.localDateToDate ?? Date(),
            removeDialogInfo: {
                if Dependencies.featureFlags().isAddonsRemovalFromMovingFlowEnabled {
                    return .init(
                        title: L10n.addonRemoveTitle(fragment.displayName),
                        description: L10n.addonRemoveDescription,
                        confirmButtonTitle: L10n.addonRemoveConfirmButton(fragment.displayName),
                        cancelButtonTitle: L10n.addonRemoveCancelButton
                    )
                }
                return nil
            }()
        )
    }
}

extension HousingType {
    fileprivate var asMoveApartmentSubType: GraphQLEnum<OctopusGraphQL.MoveApartmentSubType> {
        switch self {
        case .apartment:
            return GraphQLEnum<OctopusGraphQL.MoveApartmentSubType>(.own)
        case .rental:
            return GraphQLEnum<OctopusGraphQL.MoveApartmentSubType>(.rent)
        case .house:
            return GraphQLEnum<OctopusGraphQL.MoveApartmentSubType>(.own)
        }
    }
}
