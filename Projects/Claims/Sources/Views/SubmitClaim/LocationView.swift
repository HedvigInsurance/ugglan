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
                    return claimsNavigationVm.occurrencePlusLocationModel?.locationModel?.options
                        .compactMap({ (object: $0, displayName: .init(title: $0.displayName)) }) ?? []
                }(),
                preSelectedItems: {
                    if let value = claimsNavigationVm.occurrencePlusLocationModel?.locationModel?
                        .getSelectedOption()
                    {
                        return [value]
                    }
                    return []
                },
                onSelected: { selectedLocation in
                    if let object = selectedLocation.first?.0 {
                        claimsNavigationVm.isLocationPickerPresented = false
                        claimsNavigationVm.occurrencePlusLocationModel?.locationModel?.location =
                            object.value
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

#Preview {
    LocationView()
}
