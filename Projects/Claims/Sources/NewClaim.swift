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

public struct Payout: Decodable, Encodable, Equatable, Hashable {
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
    public var priceOfPurchase: Double?
    public var chosenModel: Model?
    public var chosenBrand: Brand?
    public var chosenDamages: [Damage]?
    public var customName: String?
    public var payoutAmount: Payout?

    init(
        id: String
    ) {
        self.id = id
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

        //        if itemModelIdInput != "" || itemModelIdInput != nil { //check
        //                    let flowClaimItemModelInput = OctopusGraphQL.FlowClaimItemModelInput(
        //                        itemModelId: itemBrandModelIdInput  //"Apple iPhone 12" or itemModelIdInput "83a5d315-42a0-4373-8b84-42377f2877b8"
        //                    )

        let flowClaimItemModelInput = OctopusGraphQL.FlowClaimItemModelInput(
            itemModelId: "83a5d315-42a0-4373-8b84-42377f2877b8"
        )

        return OctopusGraphQL.FlowClaimSingleItemInput(
            purchasePrice: purchasePrice,
            purchaseDate: formatDateToString(date: dateOfPurchase ?? Date()),
            //            itemProblemIds: ["BROKEN", "BROKEN_FRONT"],
            itemProblemIds: problemsToString,
            itemModelInput: flowClaimItemModelInput,
            customName: customName  //check
        )

        //        } else {
        //                    let flowClaimItemBrandInput = OctopusGraphQL.FlowClaimItemBrandInput(
        //                        itemTypeId: itemBrandTypeIdInput,
        //                        itemBrandId: itemBrandIdInput
        //                    )

        //        let flowClaimItemBrandInput = OctopusGraphQL.FlowClaimItemBrandInput(
        //                            itemTypeId: "PHONE",
        //                            itemBrandId: "APPLE_IPHONE"
        //                        )
        //
        //                    return OctopusGraphQL.FlowClaimSingleItemInput(
        //                        purchasePrice: purchasePrice,
        //                        purchaseDate: formatDateToString(date: dateOfPurchase ?? Date()),
        //                        itemProblemIds: ["BROKEN", "BROKEN_"], //need to add broken
        //                        itemBrandInput: flowClaimItemBrandInput,
        //                        customName: customName  //check
        //                    )

        //        }
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

        //        return OctopusGraphQL.FlowClaimSummaryInput(
        //            dateOfOccurrence: dateOfOccurrence,
        //            location: self.location?.displayValue,
        //            purchasePrice: self.priceOfPurchase,
        //            purchaseDate: dateString,
        //            itemProblemIds: damagesToString,
        //            itemBrandInput: chosenBrandInput,
        //            itemModelInput: modelIdInput,
        //            customName: self.customName
        //        )

        let flowClaimItemModelInput = OctopusGraphQL.FlowClaimItemModelInput(
            itemModelId: "83a5d315-42a0-4373-8b84-42377f2877b8"
        )
        //        return OctopusGraphQL.FlowClaimSummaryInput(
        //            dateOfOccurrence: dateOfOccurrence,
        //            location: location?.displayValue,
        //            purchasePrice: priceOfPurchase,
        //            purchaseDate: formatDateToString(date: dateOfPurchase ?? Date()),
        //            itemProblemIds: ["BROKEN", "BROKEN_FRONT"],
        ////            itemBrandInput: nil,
        //            itemModelInput: flowClaimItemModelInput,
        //            customName: customName
        //        )

        return OctopusGraphQL.FlowClaimSummaryInput()
    }
}
