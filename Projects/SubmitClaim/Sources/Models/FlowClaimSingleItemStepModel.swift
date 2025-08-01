import Foundation
import SwiftUI
import hCore
import hCoreUI

public struct FlowClaimSingleItemStepModel: FlowClaimStepModel {
    let id: String
    public let availableItemBrandOptions: [ClaimFlowItemBrandOptionModel]
    public let availableItemModelOptions: [ClaimFlowItemModelOptionModel]
    let availableItemProblems: [ClaimFlowItemProblemOptionModel]
    public internal(set) var customName: String?
    let prefferedCurrency: String?
    public internal(set) var purchaseDate: String?
    public internal(set) var purchasePrice: Double?
    let currencyCode: String?
    public internal(set) var selectedItemBrand: String?
    public internal(set) var selectedItemModel: String?
    public internal(set) var selectedItemProblems: [String]?
    public let defaultItemProblems: [String]?
    let purchasePriceApplicable: Bool

    public init(
        id: String,
        availableItemBrandOptions: [ClaimFlowItemBrandOptionModel],
        availableItemModelOptions: [ClaimFlowItemModelOptionModel],
        availableItemProblems: [ClaimFlowItemProblemOptionModel],
        customName: String? = nil,
        prefferedCurrency: String?,
        purchaseDate: String? = nil,
        purchasePrice: Double? = nil,
        currencyCode: String?,
        selectedItemBrand: String? = nil,
        selectedItemModel: String? = nil,
        selectedItemProblems: [String]? = nil,
        defaultItemProblems: [String]?,
        purchasePriceApplicable: Bool
    ) {
        self.id = id
        self.availableItemBrandOptions = availableItemBrandOptions
        self.availableItemModelOptions = availableItemModelOptions
        self.availableItemProblems = availableItemProblems
        self.customName = customName
        self.prefferedCurrency = prefferedCurrency
        self.purchaseDate = purchaseDate
        self.purchasePrice = purchasePrice
        self.currencyCode = currencyCode
        self.selectedItemBrand = selectedItemBrand
        self.selectedItemModel = selectedItemModel
        self.selectedItemProblems = selectedItemProblems
        self.defaultItemProblems = defaultItemProblems
        self.purchasePriceApplicable = purchasePriceApplicable
    }

    func getBrandOrModelName() -> String? {
        if let customName {
            return customName
        } else if let selectedItemModel {
            return availableItemModelOptions.first(where: { $0.itemModelId == selectedItemModel })?.displayName
        } else if let selectedItemBrand {
            return availableItemBrandOptions.first(where: { $0.itemBrandId == selectedItemBrand })?.displayName
        }
        return nil
    }

    func getChoosenDamagesAsText() -> String? {
        let chosenDamages = selectedItemProblems ?? []
        let availableItemProblems =
            availableItemProblems.filter { model in
                chosenDamages.contains(model.itemProblemId)
            }
            .map(\.displayName)
        if !availableItemProblems.isEmpty {
            var finalString = availableItemProblems[0]

            for availableItemProblem in availableItemProblems {
                finalString.append(", \(availableItemProblem)")
            }

            return finalString
        }
        return nil
    }

    func getAllChoosenDamagesAsText() -> String? {
        let chosenDamages = selectedItemProblems ?? []
        let availableItemProblems =
            availableItemProblems.filter { model in
                chosenDamages.contains(model.itemProblemId)
            }
            .map(\.displayName)
        if !availableItemProblems.isEmpty {
            return availableItemProblems.joined(separator: ", ")
        }
        return nil
    }

    func getListOfModels() -> [ClaimFlowItemModelOptionModel]? {
        if let selectedItemBrand {
            return getListOfModels(for: selectedItemBrand)
        }
        return nil
    }

    func getListOfModels(for brandId: String) -> [ClaimFlowItemModelOptionModel]? {
        availableItemModelOptions.filter { $0.itemBrandId == brandId }
    }

    var returnDisplayStringForSummaryPrice: String? {
        if let purchasePrice {
            return String(Int(purchasePrice)) + " " + (currencyCode ?? "")
        }
        return nil
    }
}

public struct ClaimFlowItemBrandOptionModel: Codable, Equatable, Hashable, Sendable {
    let displayName: String
    public let itemBrandId: String
    public let itemTypeId: String

    public init(
        displayName: String,
        itemBrandId: String,
        itemTypeId: String
    ) {
        self.displayName = displayName
        self.itemBrandId = itemBrandId
        self.itemTypeId = itemTypeId
    }
}

public struct ClaimFlowItemModelOptionModel: Codable, Equatable, Hashable, Sendable {
    public let displayName: String
    public let itemBrandId: String
    let itemTypeId: String
    public let itemModelId: String

    public init(
        displayName: String,
        itemBrandId: String,
        itemTypeId: String,
        itemModelId: String
    ) {
        self.displayName = displayName
        self.itemBrandId = itemBrandId
        self.itemTypeId = itemTypeId
        self.itemModelId = itemModelId
    }
}

public struct ClaimFlowItemProblemOptionModel: Codable, Equatable, Hashable, Sendable {
    let displayName: String
    let itemProblemId: String

    public init(
        displayName: String,
        itemProblemId: String
    ) {
        self.displayName = displayName
        self.itemProblemId = itemProblemId
    }
}

extension ClaimFlowItemBrandOptionModel: TrackingViewNameProtocol {
    public var nameForTracking: String {
        .init(describing: ModelPickerView.self)
    }
}
