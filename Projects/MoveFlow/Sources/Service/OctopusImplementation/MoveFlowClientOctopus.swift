import ChangeTier
import Contracts
import Foundation
import PresentableStore
import hCore
import hCoreUI
import hGraphQL

public class MoveFlowClientOctopus: MoveFlowClient {
    @Inject var octopus: hOctopus
    @PresentableStore var store: MoveFlowStore

    public init() {}

    public func sendMoveIntent() async throws -> MovingFlowModel {
        let mutation = OctopusGraphQL.MoveIntentCreateMutation()
        let data = try await octopus.client.perform(mutation: mutation)

        if let moveIntentFragment = data.moveIntentCreate.moveIntent?.fragments.moveIntentFragment {
            return MovingFlowModel(from: moveIntentFragment)
        } else if let userError = data.moveIntentCreate.userError?.message {
            throw MovingFlowError.serverError(message: userError)
        }
        throw MovingFlowError.missingDataError(message: L10n.General.errorBody)
    }

    public func requestMoveIntent(
        intentId: String,
        addressInputModel: AddressInputModel,
        houseInformationInputModel: HouseInformationInputModel
    ) async throws -> MovingFlowModel {
        let isMovingFlowWithTiersEnabled = Dependencies.featureFlags().isMovingFlowWithTiersEnabled
        let apiVersion: OctopusGraphQL.MoveApiVersion =
            isMovingFlowWithTiersEnabled
            ? OctopusGraphQL.MoveApiVersion.v2TiersAndDeductibles : OctopusGraphQL.MoveApiVersion.v1
        let moveIntentRequestInput = OctopusGraphQL.MoveIntentRequestInput(
            apiVersion: .init(apiVersion),
            moveToAddress: .init(
                street: addressInputModel.address,
                postalCode: addressInputModel.postalCode.replacingOccurrences(of: " ", with: "")
            ),
            moveFromAddressId: store.state.movingFromAddressModel?.id ?? "",
            movingDate: addressInputModel.accessDate?.localDateString ?? "",
            numberCoInsured: addressInputModel.nbOfCoInsured,
            squareMeters: Int(addressInputModel.squareArea) ?? 0,
            apartment: GraphQLNullable(optionalValue: apartmentInput(addressInputModel: addressInputModel)),
            house: GraphQLNullable(optionalValue: houseInput(houseInformationInputModel: houseInformationInputModel))
        )

        let mutation = OctopusGraphQL.MoveIntentRequestMutation(
            intentId: intentId,
            input: moveIntentRequestInput
        )

        let data = try await octopus.client.perform(mutation: mutation)
        if let moveIntentFragment = data.moveIntentRequest.moveIntent?.fragments.moveIntentFragment {
            return MovingFlowModel(from: moveIntentFragment)
        } else if let userError = data.moveIntentRequest.userError?.message {
            throw MovingFlowError.serverError(message: userError)
        }
        throw MovingFlowError.missingDataError(message: L10n.General.errorBody)
    }

    public func confirmMoveIntent(intentId: String, homeQuoteId: String?) async throws {

        let mutation = OctopusGraphQL.MoveIntentCommitMutation(
            intentId: intentId,
            homeQuoteId: GraphQLNullable.init(optionalValue: homeQuoteId)
        )
        let data = try await octopus.client.perform(mutation: mutation)

        if let userError = data.moveIntentCommit.userError {
            throw MovingFlowError.serverError(message: userError.message ?? "")
        }
    }

    private func apartmentInput(addressInputModel: AddressInputModel) -> OctopusGraphQL.MoveToApartmentInput? {
        switch store.state.selectedHousingType {
        case .apartment, .rental:
            return OctopusGraphQL.MoveToApartmentInput(
                subType: store.state.selectedHousingType.asMoveApartmentSubType,
                isStudent: addressInputModel.isStudent
            )
        case .house:
            return nil
        }
    }

    private func houseInput(houseInformationInputModel: HouseInformationInputModel) -> OctopusGraphQL.MoveToHouseInput?
    {
        switch store.state.selectedHousingType {
        case .apartment, .rental:
            return nil
        case .house:
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

extension MovingFlowModel {
    init(from data: OctopusGraphQL.MoveIntentFragment) {
        id = data.id
        let minMovingDate = data.minMovingDate
        let maxMovingDate = data.maxMovingDate
        let minMovingDateDate = minMovingDate.localDateToDate
        let maxMovingDateDate = maxMovingDate.localDateToDate
        if let minMovingDateDate, let maxMovingDateDate {
            if minMovingDateDate < maxMovingDateDate {
                self.minMovingDate = minMovingDate
                self.maxMovingDate = maxMovingDate
            } else {
                self.maxMovingDate = minMovingDate
                self.minMovingDate = maxMovingDate
            }
        } else {
            self.minMovingDate = data.minMovingDate
            self.maxMovingDate = data.maxMovingDate
        }
        isApartmentAvailableforStudent = data.isApartmentAvailableforStudent ?? false
        maxApartmentNumberCoInsured = data.maxApartmentNumberCoInsured
        maxApartmentSquareMeters = data.maxApartmentSquareMeters
        maxHouseNumberCoInsured = data.maxHouseNumberCoInsured
        maxHouseSquareMeters = data.maxHouseSquareMeters

        suggestedNumberCoInsured = data.suggestedNumberCoInsured
        currentHomeAddresses = data.currentHomeAddresses.compactMap({
            MoveAddress(from: $0.fragments.moveAddressFragment)
        })
        let quotes = data.fragments.quoteFragment.quotes

        self.potentialHomeQuotes = data.homeQuotes?.compactMap({ Quote(from: $0) }) ?? []

        if !quotes.isEmpty {
            self.quotes = data.fragments.quoteFragment.quotes.compactMap({ Quote(from: $0) })
        } else if let homeQuotes = data.fragments.quoteFragment.mtaQuotes {
            self.quotes = homeQuotes.compactMap({ Quote(from: $0) })
        } else {
            self.quotes = []
        }
        changeTier = {
            if let data = data.fragments.quoteFragment.homeQuotes, !data.isEmpty {
                return ChangeTierIntentModel.initWith(data: data)
            }
            return nil
        }()

        self.extraBuildingTypes = data.extraBuildingTypes.compactMap({ $0.rawValue })

        var faqs = [FAQ]()
        faqs.append(.init(title: L10n.changeAddressFaqDateTitle, description: L10n.changeAddressFaqDateLabel))
        faqs.append(.init(title: L10n.changeAddressFaqPriceTitle, description: L10n.changeAddressFaqPriceLabel))
        faqs.append(.init(title: L10n.changeAddressFaqRentbrfTitle, description: L10n.changeAddressFaqRentbrfLabel))
        faqs.append(.init(title: L10n.changeAddressFaqStorageTitle, description: L10n.changeAddressFaqStorageLabel))
        faqs.append(.init(title: L10n.changeAddressFaqStudentTitle, description: L10n.changeAddressFaqStudentLabel))
        self.faqs = faqs
    }
}

extension MoveAddress {
    init(from data: OctopusGraphQL.MoveAddressFragment) {
        id = data.id
        street = data.street
        postalCode = data.postalCode
        city = data.city
    }
}

extension Quote {
    init(from data: OctopusGraphQL.QuoteFragment.Quote) {
        id = UUID().uuidString
        premium = .init(fragment: data.premium.fragments.moneyFragment)
        startDate = data.startDate.localDateToDate?.displayDateDDMMMYYYYFormat ?? data.startDate
        let productVariantFragment = data.productVariant.fragments.productVariantFragment
        displayName = productVariantFragment.displayName
        exposureName = data.exposureName
        insurableLimits = productVariantFragment.insurableLimits.compactMap({
            .init(label: $0.label, limit: $0.limit, description: $0.description)
        })
        perils = productVariantFragment.perils.compactMap({ .init(fragment: $0) })
        documents = productVariantFragment.documents.compactMap({ .init($0) })
        contractType = TypeOfContract(rawValue: data.productVariant.typeOfContract)
        displayItems = data.displayItems.map({ .init($0) })
    }

    init(from data: OctopusGraphQL.QuoteFragment.MtaQuote) {
        id = UUID().uuidString
        premium = .init(fragment: data.premium.fragments.moneyFragment)
        startDate = data.startDate.localDateToDate?.displayDateDDMMMYYYYFormat ?? data.startDate
        let productVariantFragment = data.productVariant.fragments.productVariantFragment
        displayName = productVariantFragment.displayName
        exposureName = data.exposureName
        insurableLimits = productVariantFragment.insurableLimits.compactMap({
            .init(label: $0.label, limit: $0.limit, description: $0.description)
        })
        perils = productVariantFragment.perils.compactMap({ .init(fragment: $0) })
        documents = productVariantFragment.documents.compactMap({ .init($0) })
        contractType = TypeOfContract(rawValue: data.productVariant.typeOfContract)
        displayItems = data.displayItems.map({ .init($0) })
    }

    init(from data: OctopusGraphQL.QuoteFragment.HomeQuote) {
        id = data.id
        premium = .init(fragment: data.premium.fragments.moneyFragment)
        startDate = data.startDate.localDateToDate?.displayDateDDMMMYYYYFormat ?? data.startDate
        let productVariantFragment = data.productVariant.fragments.productVariantFragment
        displayName = productVariantFragment.displayName
        exposureName = data.exposureName
        insurableLimits = productVariantFragment.insurableLimits.compactMap({
            .init(label: $0.label, limit: $0.limit, description: $0.description)
        })
        perils = productVariantFragment.perils.compactMap({ .init(fragment: $0) })
        documents = productVariantFragment.documents.compactMap({ .init($0) })
        contractType = TypeOfContract(rawValue: data.productVariant.typeOfContract)
        displayItems = data.displayItems.map({ .init($0) })
    }
}

extension InsuranceDocument {
    init(_ data: OctopusGraphQL.ProductVariantFragment.Document) {
        self.displayName = data.displayName
        self.url = data.url
    }
}

extension DisplayItem {
    init(_ data: OctopusGraphQL.QuoteFragment.Quote.DisplayItem) {
        displaySubtitle = data.displaySubtitle
        displayTitle = data.displayTitle
        displayValue = data.displayValue
    }

    init(_ data: OctopusGraphQL.QuoteFragment.MtaQuote.DisplayItem) {
        displaySubtitle = data.displaySubtitle
        displayTitle = data.displayTitle
        displayValue = data.displayValue
    }

    init(_ data: OctopusGraphQL.QuoteFragment.HomeQuote.DisplayItem) {
        displaySubtitle = data.displaySubtitle
        displayTitle = data.displayTitle
        displayValue = data.displayValue
    }
}

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
                let deductibles = quotes.compactMap { quote in
                    return Deductible(
                        id: quote.id,
                        deductibleAmount: .init(optionalFragment: quote.deductible?.amount.fragments.moneyFragment),
                        deductiblePercentage: (quote.deductible?.percentage == 0) ? nil : quote.deductible?.percentage,
                        subTitle: quote.deductible?.displayText,
                        premium: .init(fragment: quote.premium.fragments.moneyFragment)
                    )
                }
                let tier = Tier(
                    id: firstQuote.tierName,
                    name: firstQuote.tierName,
                    level: firstQuote.tierLevel,
                    deductibles: deductibles,
                    premium: .init(fragment: firstQuote.premium.fragments.moneyFragment),
                    displayItems: [],
                    exposureName: firstQuote.exposureName,
                    productVariant: ProductVariant(data: firstQuote.productVariant.fragments.productVariantFragment),
                    FAQs: []
                )
                return tier
            }
            return nil
        }

        let currentTierAndDeductible: (tier: Tier?, deductible: Deductible?) = {
            if let defaultChoise = data.first(where: { $0.defaultChoice }),
                let currentTier = tiers.first(where: { $0.id == defaultChoise.tierName }),
                let currentDeductible = currentTier.deductibles.first(where: { $0.id == defaultChoise.id })
            {
                return (currentTier, currentDeductible)
            }
            return (nil, nil)
        }()
        let intentModel: ChangeTierIntentModel = .init(
            activationDate: data.first?.startDate.localDateToDate ?? Date(),
            tiers: tiers,
            currentPremium: nil,
            currentTier: nil,
            currentDeductible: nil,
            selectedTier: currentTierAndDeductible.tier,
            selectedDeductible: currentTierAndDeductible.deductible,
            canEditTier: true,
            typeOfContract: TypeOfContract.resolve(for: data.first?.productVariant.typeOfContract ?? "")
        )
        return intentModel
    }

}
