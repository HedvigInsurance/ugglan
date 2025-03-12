import SwiftUI
import hCore
import hCoreUI

struct ModelPickerView: View {
    @ObservedObject var router: Router
    @ObservedObject var claimsNavigationVm: ClaimsNavigationViewModel
    let brand: ClaimFlowItemBrandOptionModel
    var itemConfig: ItemConfig<ClaimFlowItemModelOptionModel>

    init(router: Router, claimsNavigationVm: ClaimsNavigationViewModel, brand: ClaimFlowItemBrandOptionModel) {
        self.router = router
        self.claimsNavigationVm = claimsNavigationVm
        self.brand = brand
        let step = claimsNavigationVm.singleItemModel
        let customName = step?.selectedItemBrand == brand.itemBrandId ? step?.customName : nil
        self.itemConfig = .init(
            items: {
                return step?.getListOfModels(for: brand.itemBrandId)?
                    .compactMap({ ($0, .init(title: $0.displayName)) }) ?? []

            }(),
            preSelectedItems: {
                if let item = step?.getListOfModels()?.first(where: { $0.itemModelId == step?.selectedItemModel }) {
                    return [item]
                }
                return []
            },
            onSelected: { [weak router] item in
                if item.first?.0 == nil {
                    claimsNavigationVm.singleItemModel?.selectedItemBrand = brand.itemBrandId
                    let customName = item.first?.1 ?? ""
                    claimsNavigationVm.singleItemModel?.customName = customName
                    claimsNavigationVm.singleItemModel?.selectedItemModel = nil
                } else {
                    if let object = item.first?.0 {
                        claimsNavigationVm.singleItemModel?.selectedItemBrand = brand.itemBrandId
                        claimsNavigationVm.singleItemModel?.customName = nil
                        claimsNavigationVm.singleItemModel?.selectedItemModel = object.itemModelId
                    }
                }
                router?.dismiss()
            },
            onCancel: { [weak router] in
                router?.dismiss()
            },
            singleSelect: true,
            manualInputPlaceholder: L10n.Claims.Item.Enter.Model.name,
            manualBrandName: customName,
            contentPosition: .top,
            useAlwaysAttachedToBottom: true
        )
    }

    var body: some View {
        return ItemPickerScreen<ClaimFlowItemModelOptionModel>(
            config: itemConfig
        )
        .hIncludeManualInput
    }
}

#Preview {
    ModelPickerView(
        router: Router(),
        claimsNavigationVm: .init(),
        brand: .init(displayName: "displayName", itemBrandId: "brandId", itemTypeId: "type")
    )
}
