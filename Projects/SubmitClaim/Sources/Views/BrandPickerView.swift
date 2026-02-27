import SwiftUI
import hCoreUI

struct BrandPickerView: View {
    @EnvironmentObject var router: NavigationRouter
    @EnvironmentObject var claimsNavigationVm: SubmitClaimNavigationViewModel

    var body: some View {
        SubmitClaimListScreen<ClaimFlowItemBrandOptionModel>(
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
