import Presentation
import SwiftUI
import hCore
import hCoreUI

struct SelectContractScreen: View {
    var body: some View {
        PresentableStoreLens(
            SubmitClaimStore.self,
            getter: { state in
                state.contractStep
            }
        ) { contractStep in
            CheckboxPickerScreen<FlowClaimContractSelectOptionModel>(
                items: {
                    return contractStep?.availableContractOptions
                        .compactMap({ (object: $0, displayName: $0.displayName) }) ?? []
                }(),
                preSelectedItems: { [] },
                onSelected: { selectedContract in
                    let store: SubmitClaimStore = globalPresentableStoreContainer.get()
                    store.send(.contractSelectRequest(contractId: selectedContract.first?.id))
                },
                singleSelect: true
            )
        }

    }
}

struct SelectContractScreen_Previews: PreviewProvider {
    static var previews: some View {
        SelectContractScreen()
    }
}
