import StoreContainer
import SwiftUI
import hCore
import hCoreUI

struct LocationView: View {
    @EnvironmentObject var claimsNavigationVm: ClaimsNavigationViewModel
    @EnvironmentObject var router: Router
    var body: some View {
        ItemPickerScreen<ClaimFlowLocationOptionModel>(
            config: .init(
                items: {
                    let store: SubmitClaimStore = hGlobalPresentableStoreContainer.get()
                    return store.state.locationStep?.options
                        .compactMap({ (object: $0, displayName: .init(title: $0.displayName)) }) ?? []
                }(),
                preSelectedItems: {
                    let store: SubmitClaimStore = hGlobalPresentableStoreContainer.get()
                    if let value = store.state.locationStep?.getSelectedOption() {
                        return [value]
                    }
                    return []
                },
                onSelected: { selectedLocation in
                    if let object = selectedLocation.first?.0 {
                        claimsNavigationVm.isLocationPickerPresented = false
                        let store: SubmitClaimStore = hGlobalPresentableStoreContainer.get()
                        store.send(.setNewLocation(location: object))
                    }
                },
                onCancel: {
                    router.dismiss()
                },
                singleSelect: true
            )
        )
    }
}

#Preview{
    LocationView()
}
