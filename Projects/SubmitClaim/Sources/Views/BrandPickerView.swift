import SwiftUI
import hCore
import hCoreUI

struct BrandPickerView: View {
    @EnvironmentObject var router: Router
    @EnvironmentObject var claimsNavigationVm: SubmitClaimNavigationViewModel

    var body: some View {
        ListScreen<ClaimFlowItemBrandOptionModel>(
            items: claimsNavigationVm.singleItemModel?.availableItemBrandOptions
                .compactMap { (object: $0, displayName: $0.displayName) } ?? [],
            onSelected: { [weak router] item in
                router?.push(item)
            },
            onCancel: { [weak router] in
                router?.dismiss()
            }
        )
    }
}

#Preview {
    BrandPickerView()
}
