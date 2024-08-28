import StoreContainer
import SwiftUI
import hCore
import hCoreUI

struct ModelPickerView: View {
    @EnvironmentObject var router: Router
    @hPresentableStore var store: SubmitClaimStore
    let brand: ClaimFlowItemBrandOptionModel

    var body: some View {
        let step = store.state.singleItemStep
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
                onSelected: { [weak store, weak router] item in guard let store = store else { return }
                    if item.first?.0 == nil {
                        let customName = item.first?.1 ?? ""
                        store.send(.setItemModel(model: .custom(brand: brand, name: customName)))
                    } else {
                        if let object = item.first?.0 {
                            store.send(.setItemModel(model: .model(object)))
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

#Preview{
    ModelPickerView(brand: .init(displayName: "displayName", itemBrandId: "brandId", itemTypeId: "type"))
}
