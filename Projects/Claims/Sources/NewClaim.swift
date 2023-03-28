import Foundation
import hGraphQL

public struct Location: Decodable, Encodable, Equatable, Hashable {
    public var displayValue: String
    public var value: String
}

public struct Brand: Decodable, Encodable, Equatable, Hashable {
    public var displayName: String
    public var itemBrandId: String?
    public var itemTypeId: String?
}

public struct Model: Decodable, Encodable, Equatable, Hashable {
    public var displayName: String
    public var imageURL: String?
    public var itemBrandId: String
    public var itemModelId: String
    public var itemTypeID: String
}

public struct Damage: Decodable, Encodable, Equatable, Hashable {
    public var displayName: String
    public var itemProblemId: String
}

public struct Amount: Decodable, Encodable, Equatable, Hashable {
    public var amount: Double
    public var currencyCode: String
}

public struct NewClaim: Codable, Equatable {

    public let id: String
    public var dateOfOccurrence: String?
    public var location: Location?
    public var listOfLocation: [Location]?
    public var listOfDamage: [Damage]?
    public var listOfModels: [Model]?
    public var filteredListOfModels: [Model]?
    public var listOfBrands: [Brand]?
    public var dateOfPurchase: Date?
    public var priceOfPurchase: Amount?
    public var chosenModel: Model?
    public var chosenBrand: Brand?
    public var chosenDamages: [Damage]?
    public var payoutAmount: Amount?
    public var deductible: Amount?
    public var depreciation: Amount?
    public var prefferedCurrency: String?
    public var context: String
    public var maxDateOfoccurrance: String?

    init(
        id: String,
        context: String
    ) {
        self.id = id
        self.context = context
    }

    public func returnSingleItemInfo(purchasePrice: Double) -> OctopusGraphQL.FlowClaimSingleItemInput {
        let itemBrandIdInput = chosenBrand?.itemBrandId ?? ""
        let itemBrandTypeIdInput = chosenBrand?.itemTypeId ?? ""

        let itemModelIdInput = chosenModel?.itemModelId ?? ""
        let itemModelTypeIdInput = chosenModel?.itemTypeID ?? ""

        var problemsToString: [String] = []
        for element in chosenDamages ?? [] {
            problemsToString.append(element.itemProblemId)
        }

        if itemModelIdInput != "" {
            let flowClaimItemModelInput = OctopusGraphQL.FlowClaimItemModelInput(
                itemModelId: itemModelIdInput
            )

            return OctopusGraphQL.FlowClaimSingleItemInput(
                purchasePrice: purchasePrice,
                purchaseDate: formatDateToString(date: dateOfPurchase ?? Date()),
                itemProblemIds: problemsToString,
                itemModelInput: flowClaimItemModelInput
            )

        } else {

            let flowClaimItemBrandInput = OctopusGraphQL.FlowClaimItemBrandInput(
                itemTypeId: itemBrandTypeIdInput,
                itemBrandId: itemBrandIdInput
            )

            return OctopusGraphQL.FlowClaimSingleItemInput(
                purchasePrice: purchasePrice,
                purchaseDate: formatDateToString(date: dateOfPurchase ?? Date()),
                itemProblemIds: problemsToString,
                itemBrandInput: flowClaimItemBrandInput
            )
        }
    }

    public func returnSingleItemCheckoutInfo() -> OctopusGraphQL.FlowClaimSingleItemCheckoutInput {

        let automaticAutogiroInput = OctopusGraphQL.FlowClaimAutomaticAutogiroPayoutInput(
            amount: payoutAmount?.amount ?? 0
        )

        return OctopusGraphQL.FlowClaimSingleItemCheckoutInput(
            automaticAutogiro: automaticAutogiroInput
        )
    }

    public func formatDateToString(date: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let dateString = dateFormatter.string(from: date)
        return dateString
    }

    public func formatStringToDate(dateString: String) -> Date {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let date = dateFormatter.date(from: dateString) ?? Date()
        return date
    }

    public func returnSummaryInformation() -> OctopusGraphQL.FlowClaimSummaryInput {

        let modelIdInput = OctopusGraphQL.FlowClaimItemModelInput(itemModelId: chosenModel?.itemModelId ?? "")
        let chosenBrandInput = OctopusGraphQL.FlowClaimItemBrandInput(
            itemTypeId: chosenBrand?.itemTypeId ?? "",
            itemBrandId: chosenBrand?.itemBrandId ?? ""
        )

        var damagesToString: [String] = []
        for element in chosenDamages ?? [] {
            damagesToString.append(element.itemProblemId)
        }

        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let dateString = dateFormatter.string(from: dateOfPurchase ?? Date())

        return OctopusGraphQL.FlowClaimSummaryInput()
    }

    func getChoosenDamages() -> String? {
        if let chosenDamages, !chosenDamages.isEmpty {
            var finalString = chosenDamages[0].displayName
            if chosenDamages.count > 1 {
                finalString.append(", \(chosenDamages[1].displayName)")
            }
            return finalString
        }
        return nil
    }

    func getListOfModels(for brand: Brand) -> [Model]? {
        return listOfModels?.filter({ $0.itemBrandId == brand.itemBrandId })
    }
}
