import Presentation
import SwiftUI
import hCore
import hCoreUI

struct BrandPickerView: View {
    @EnvironmentObject var router: Router
    var body: some View {
        ListScreen<ClaimFlowItemBrandOptionModel>(
            items: {
                let store: SubmitClaimStore = globalPresentableStoreContainer.get()
                return store.state.singleItemStep?.availableItemBrandOptions
                    .compactMap({ (object: $0, displayName: $0.displayName) }) ?? []
            }(),
            onSelected: { [weak router] item in
                let store: SubmitClaimStore = globalPresentableStoreContainer.get()
                store.send(.setItemBrand(brand: item))
                router?.push(item)

            },
            onCancel: { [weak router] in
                router?.dismiss()
            }
        )
    }
}

#Preview{
    BrandPickerView()
}
