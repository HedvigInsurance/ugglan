import Presentation
import SwiftUI
import hCore
import hCoreUI

struct SelectContractScreen: View {
    @PresentableStore var store: SubmitClaimStore
    @State var isLoading: Bool = false
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
                preSelectedItems: {
                    if let preselected = contractStep?.availableContractOptions
                        .first(where: { $0.id == contractStep?.selectedContractId })
                    {
                        return [preselected]
                    }
                    return []
                },
                onSelected: { selectedContract in
                    let store: SubmitClaimStore = globalPresentableStoreContainer.get()
                    store.send(.contractSelectRequest(contractId: selectedContract.first?.id))
                },
                singleSelect: true,
                attachToBottom: true
            )
            .padding(.bottom, 16)
            .hFormTitle(.small, .title1, L10n.claimTriagingAboutTitile)
            .hButtonIsLoading(isLoading)
            .hDisableScroll
            .onReceive(
                store.loadingSignal
                    .plain()
                    .publisher
            ) { value in
                withAnimation {
                    isLoading = value[.postContractSelect] == .loading
                }
            }
        }

    }
}

struct SelectContractScreen_Previews: PreviewProvider {
    static var previews: some View {
        SelectContractScreen()
    }
}
