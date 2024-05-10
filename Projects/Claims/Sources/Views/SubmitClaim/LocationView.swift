import Presentation
import SwiftUI
import hCore
import hCoreUI

struct LocationView: View {
    @EnvironmentObject var claimsNavigationVm: ClaimsNavigationViewModel
    @EnvironmentObject var router: Router
    var body: some View {
        CheckboxPickerScreen<ClaimFlowLocationOptionModel>(
            items: {
                let store: SubmitClaimStore = globalPresentableStoreContainer.get()
                return store.state.locationStep?.options
                    .compactMap({ (object: $0, displayName: .init(title: $0.displayName)) }) ?? []
            }(),
            preSelectedItems: {
                let store: SubmitClaimStore = globalPresentableStoreContainer.get()
                if let value = store.state.locationStep?.getSelectedOption() {
                    return [value]
                }
                return []
            },
            onSelected: { selectedLocation in
                if let object = selectedLocation.first?.0 {
                    claimsNavigationVm.isLocationPickerPresented = false
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
                        let store: SubmitClaimStore = globalPresentableStoreContainer.get()
                        store.send(.setNewLocation(location: object))
                    }
                }
            },
            onCancel: {
                router.dismiss()
            },
            singleSelect: true
        )
    }
}

#Preview{
    LocationView()
}
