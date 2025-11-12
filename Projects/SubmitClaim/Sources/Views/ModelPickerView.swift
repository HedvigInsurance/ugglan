import SwiftUI
import hCore
import hCoreUI

struct ModelPickerView: View {
    @ObservedObject var claimsNavigationVm: SubmitClaimNavigationViewModel
    @ObservedObject var router: Router
    var itemPickerConfig: ItemConfig<ClaimFlowItemModelOptionModel>

    init(router: Router, claimsNavigationVm: SubmitClaimNavigationViewModel, brand: ClaimFlowItemBrandOptionModel) {
        self.router = router
        self.claimsNavigationVm = claimsNavigationVm
        let step = claimsNavigationVm.singleItemModel
        let customName = step?.selectedItemBrand == brand.itemBrandId ? step?.customName : nil
        itemPickerConfig = .init(
            items: step?.getListOfModels(for: brand.itemBrandId)?
                .compactMap { ($0, .init(title: $0.displayName)) } ?? [],
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
            manualInputConfig: .init(
                placeholder: L10n.Claims.Item.Enter.Model.name,
                brandName: customName
            )
        )
    }

    var body: some View {
        ItemPickerScreen<ClaimFlowItemModelOptionModel>(
            config: itemPickerConfig
        )
        .hItemPickerAttributes([.singleSelect, .alwaysAttachToBottom])
        .hFormContentPosition(.top)
    }
}

#Preview {
    ModelPickerView(
        router: Router(),
        claimsNavigationVm: .init(),
        brand: .init(displayName: "displayName", itemBrandId: "brandId", itemTypeId: "type")
    )
}
