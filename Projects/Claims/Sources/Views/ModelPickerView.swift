import PresentableStore
import SwiftUI
import hCore
import hCoreUI

struct ModelPickerView: View {
    @EnvironmentObject var router: Router
    @EnvironmentObject var claimsNavigationVm: ClaimsNavigationViewModel
    let brand: ClaimFlowItemBrandOptionModel

    var body: some View {
        let step = claimsNavigationVm.singleItemModel
        let customName = step?.selectedItemBrand == brand.itemBrandId ? step?.customName : nil
        return ItemPickerScreen<ClaimFlowItemModelOptionModel>(
            config: .init(
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
                manualBrandName: customName
            )
        )
        .hIncludeManualInput
    }
}

#Preview {
    ModelPickerView(brand: .init(displayName: "displayName", itemBrandId: "brandId", itemTypeId: "type"))
}
