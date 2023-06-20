import Foundation
import hCore
import hGraphQL

public struct FlowClamSingleItemStepModel: FlowClaimStepModel {
    let id: String
    let availableItemBrandOptions: [ClaimFlowItemBrandOptionModel]
    let availableItemModelOptions: [ClaimFlowItemModelOptionModel]
    let availableItemProblems: [ClaimFlowItemProblemOptionModel]
    let customName: String?
    let prefferedCurrency: String?
    var purchaseDate: String?
    var purchasePrice: Double?
    let currencyCode: String?
    var selectedItemBrand: String?
    var selectedItemModel: String?
    var selectedItemProblems: [String]?
    let defaultItemProblems: [String]?

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
        self.selectedItemProblems = data.selectedItemProblems
        self.defaultItemProblems = data.selectedItemProblems
    }

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
            purchasePrice: purchasePrice == 0 ? nil : purchasePrice,
            purchaseDate: purchaseDate,
            itemProblemIds: problemsIds,
            itemBrandInput: itemBrandInput,
            itemModelInput: itemModelInput,
            customName: nil
        )
    }

    func getBrandOrModelName() -> String? {
        if let selectedItemModel {
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

    func shouldShowListOfModels(for brand: ClaimFlowItemBrandOptionModel) -> Bool {
        return !(self.getListOfModels(for: brand.itemBrandId)?.isEmpty ?? true)
    }

    var returnDisplayStringForSummary: String {
        var textParts: [String] = []
        if let purchaseDate {
            let purchaseDateText = L10n.summaryPurchaseDateDescription(purchaseDate)
            textParts.append(purchaseDateText)
        }

        if let purchasePrice {
            let purchasePriceText =
                L10n.summaryPurchasePriceDescription(Int(purchasePrice)) + " " + (currencyCode ?? "")
            textParts.append(purchasePriceText)
        }

        return textParts.joined(separator: " · ")
    }

    var returnDisplayStringForSummaryDate: String? {
        if let purchaseDate {
            return L10n.summaryPurchaseDateDescription(purchaseDate)
        }
        return nil
    }

    var returnDisplayStringForSummaryPrice: String? {
        if let purchasePrice {
            return String(Int(purchasePrice)) + " " + (currencyCode ?? "")
        }
        return nil
    }
}

public struct ClaimFlowItemBrandOptionModel: Codable, Equatable, Hashable {
    let displayName: String
    let itemBrandId: String
    let itemTypeId: String

    init(
        with model: OctopusGraphQL.FlowClaimSingleItemStepFragment.AvailableItemBrand
    ) {
        self.displayName = model.displayName
        self.itemBrandId = model.itemBrandId
        self.itemTypeId = model.itemTypeId
    }
}

public struct ClaimFlowItemModelOptionModel: Codable, Equatable, Hashable {
    let displayName: String
    let itemBrandId: String
    let itemTypeId: String
    let itemModelId: String

    init(
        with model: OctopusGraphQL.FlowClaimSingleItemStepFragment.AvailableItemModel
    ) {
        self.displayName = model.displayName
        self.itemBrandId = model.itemBrandId
        self.itemTypeId = model.itemTypeId
        self.itemModelId = model.itemModelId
    }
}

public struct ClaimFlowItemProblemOptionModel: Codable, Equatable, Hashable {
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
