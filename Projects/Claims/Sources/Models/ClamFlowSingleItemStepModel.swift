import Foundation
import hGraphQL

struct ClamFlowSingleItemStepModel: ClaimFlowStepModel {
    let id: String
    let availableItemBrandOptions: [ClaimFlowItemBrandOptionModel]
    let availableItemModelOptions: [ClaimFlowItemModelOptionModel]
    let availableItemProblems: [ClaimFlowItemProblemOptionModel]
    let customName: String?
    let prefferedCurrency: String
    let purchaseDate: String?
    let purchasePrice: Double?
    let currencyCode: String?
    let selectedItemBrand: String?
    let selectedItemModel: String?
    let selectedItemProblems: [String]?
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
    }
}

struct ClaimFlowItemBrandOptionModel: Codable, Equatable {
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

struct ClaimFlowItemModelOptionModel: Codable, Equatable {
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

struct ClaimFlowItemProblemOptionModel: Codable, Equatable {
    let displayName: String
    let itemProblemId: String

    init(
        with model: OctopusGraphQL.FlowClaimSingleItemStepFragment.AvailableItemProblem
    ) {
        self.displayName = model.displayName
        self.itemProblemId = model.itemProblemId
    }
}
