import Foundation
import SwiftUI
import hCore
import hCoreUI
import hGraphQL

public struct FlowClaimSingleItemStepModel: FlowClaimStepModel {
    let id: String
    let availableItemBrandOptions: [ClaimFlowItemBrandOptionModel]
    let availableItemModelOptions: [ClaimFlowItemModelOptionModel]
    let availableItemProblems: [ClaimFlowItemProblemOptionModel]
    var customName: String?
    let prefferedCurrency: String?
    var purchaseDate: String?
    var purchasePrice: Double?
    let currencyCode: String?
    var selectedItemBrand: String?
    var selectedItemModel: String?
    var selectedItemProblems: [String]?
    let defaultItemProblems: [String]?
    let purchasePriceApplicable: Bool

    init(
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

    @MainActor
    init(
        with data: OctopusGraphQL.FlowClaimSingleItemStepFragment
    ) {
        self.id = data.id
        self.availableItemBrandOptions =
            data.availableItemBrands?.map({ ClaimFlowItemBrandOptionModel.init(with: $0) }) ?? []
        self.availableItemModelOptions =
            data.availableItemModels?.map({ ClaimFlowItemModelOptionModel.init(with: $0) }) ?? []
        self.availableItemProblems =
            data.availableItemProblems?.map({ ClaimFlowItemProblemOptionModel.init(with: $0) }) ?? []
        self.customName = data.customName
        self.prefferedCurrency = data.preferredCurrency.rawValue
        self.purchaseDate = data.purchaseDate
        self.purchasePrice = data.purchasePrice?.amount
        self.currencyCode = data.purchasePrice?.currencyCode.rawValue
        self.selectedItemBrand = data.selectedItemBrand
        self.selectedItemModel = data.selectedItemModel
        self.purchasePriceApplicable = data.purchasePriceApplicable

        if self.selectedItemModel == nil && self.customName == nil {
            let currentDeviceName = UIDevice.modelName.lowercased()
            if let matchingModelWithCurrentDevice = self.availableItemModelOptions.first(where: {
                let name = $0.displayName.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
                return name == currentDeviceName
            }) {
                self.selectedItemModel = matchingModelWithCurrentDevice.itemModelId
                self.selectedItemBrand = matchingModelWithCurrentDevice.itemBrandId
            }
        }

        self.selectedItemProblems = data.selectedItemProblems
        self.defaultItemProblems = data.selectedItemProblems
    }

    @MainActor
    public func returnSingleItemInfo(purchasePrice: Double?) -> OctopusGraphQL.FlowClaimSingleItemInput {
        let itemBrandInput: OctopusGraphQL.FlowClaimItemBrandInput? = {
            if selectedItemModel != nil {
                return nil
            }
            guard let selectedItemBrand,
                let selectedBrand = availableItemBrandOptions.first(where: { $0.itemBrandId == selectedItemBrand })
            else {
                return nil
            }
            return OctopusGraphQL.FlowClaimItemBrandInput(
                itemTypeId: selectedBrand.itemTypeId,
                itemBrandId: selectedBrand.itemBrandId
            )
        }()

        let itemModelInput: OctopusGraphQL.FlowClaimItemModelInput? = {
            guard let selectedItemModel else { return nil }
            return OctopusGraphQL.FlowClaimItemModelInput(itemModelId: selectedItemModel)

        }()

        let problemsIds = self.selectedItemProblems ?? defaultItemProblems ?? []
        return OctopusGraphQL.FlowClaimSingleItemInput(
            purchasePrice: GraphQLNullable(optionalValue: purchasePrice == 0 ? nil : purchasePrice),
            purchaseDate: GraphQLNullable(optionalValue: purchaseDate?.localDateToDate?.localDateString),
            itemProblemIds: GraphQLNullable(optionalValue: problemsIds),
            itemBrandInput: GraphQLNullable(optionalValue: itemBrandInput),
            itemModelInput: GraphQLNullable(optionalValue: itemModelInput),
            customName: GraphQLNullable(optionalValue: customName)
        )
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
        let chosenDamages = self.selectedItemProblems ?? []
        let availableItemProblems =
            availableItemProblems.filter { model in
                return chosenDamages.contains(model.itemProblemId)
            }
            .map({ $0.displayName })
        if !availableItemProblems.isEmpty {
            var finalString = availableItemProblems[0]
            if availableItemProblems.count > 1 {
                finalString.append(", \(availableItemProblems[1])")
            }
            if availableItemProblems.count > 2 {
                finalString.append(" ...")
            }
            return finalString
        }
        return nil
    }

    func getAllChoosenDamagesAsText() -> String? {
        let chosenDamages = self.selectedItemProblems ?? []
        let availableItemProblems =
            availableItemProblems.filter { model in
                return chosenDamages.contains(model.itemProblemId)
            }
            .map({ $0.displayName })
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
        return availableItemModelOptions.filter({ $0.itemBrandId == brandId })
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
    let itemBrandId: String
    let itemTypeId: String

    init(
        displayName: String,
        itemBrandId: String,
        itemTypeId: String
    ) {
        self.displayName = displayName
        self.itemBrandId = itemBrandId
        self.itemTypeId = itemTypeId
    }

    init(
        with model: OctopusGraphQL.FlowClaimSingleItemStepFragment.AvailableItemBrand
    ) {
        self.displayName = model.displayName
        self.itemBrandId = model.itemBrandId
        self.itemTypeId = model.itemTypeId
    }
}

public struct ClaimFlowItemModelOptionModel: Codable, Equatable, Hashable, Sendable {
    let displayName: String
    let itemBrandId: String
    let itemTypeId: String
    let itemModelId: String

    init(
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

    init(
        with model: OctopusGraphQL.FlowClaimSingleItemStepFragment.AvailableItemModel
    ) {
        self.displayName = model.displayName
        self.itemBrandId = model.itemBrandId
        self.itemTypeId = model.itemTypeId
        self.itemModelId = model.itemModelId
    }
}

public struct ClaimFlowItemProblemOptionModel: Codable, Equatable, Hashable, Sendable {
    let displayName: String
    let itemProblemId: String

    init(
        displayName: String,
        itemProblemId: String
    ) {
        self.displayName = displayName
        self.itemProblemId = itemProblemId
    }

    init(
        with model: OctopusGraphQL.FlowClaimSingleItemStepFragment.AvailableItemProblem
    ) {
        self.displayName = model.displayName
        self.itemProblemId = model.itemProblemId
    }
}

extension ClaimFlowItemBrandOptionModel: TrackingViewNameProtocol {
    public var nameForTracking: String {
        return .init(describing: ModelPickerView.self)
    }
}
