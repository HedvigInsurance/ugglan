import SwiftUI
import hCore
import hCoreUI

struct LocationView: View {
    @ObservedObject var claimsNavigationVm: SubmitClaimNavigationViewModel
    @ObservedObject var router: Router
    let itemPickerConfig: ItemConfig<ClaimFlowLocationOptionModel>

    init(claimsNavigationVm: SubmitClaimNavigationViewModel, router: Router) {
        self.claimsNavigationVm = claimsNavigationVm
        self.router = router
        itemPickerConfig = .init(
            items: claimsNavigationVm.occurrencePlusLocationModel?.locationModel?.options
                .compactMap { (object: $0, displayName: .init(title: $0.displayName)) } ?? [],
            preSelectedItems: {
                if let value = claimsNavigationVm.occurrencePlusLocationModel?.locationModel?
                    .getSelectedOption()
                {
                    return [value]
                }
                return []
            },
            onSelected: { [weak claimsNavigationVm] selectedLocation in
                if let object = selectedLocation.first?.0 {
                    claimsNavigationVm?.isLocationPickerPresented = false
                    claimsNavigationVm?.occurrencePlusLocationModel?.locationModel?.location =
                        object.value
                }
            },
            onCancel: { [weak router] in
                router?.dismiss()
            }
        )
    }

    var body: some View {
        ItemPickerScreen<ClaimFlowLocationOptionModel>(
            config: itemPickerConfig
        )
        .hItemPickerAttributes([.singleSelect])
        .hFormContentPosition(.compact)
    }
}

#Preview {
    Dependencies.shared.add(module: Module { () -> hFetchEntrypointsClient in FetchEntrypointsClientDemo() })
    return LocationView(claimsNavigationVm: .init(), router: .init())
}
