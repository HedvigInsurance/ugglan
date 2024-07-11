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
                config: .init(
                    items: {
                        return contractStep?.availableContractOptions
                            .compactMap({ (object: $0, displayName: .init(title: $0.displayName)) }) ?? []
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
                        if let object = selectedContract.first?.0 {
                            store.send(.contractSelectRequest(contractId: object.id))
                        }
                    },
                    singleSelect: true,
                    attachToBottom: true
                )
            )
            .padding(.bottom, .padding16)
            .hFormTitle(title: .init(.small, .title1, L10n.claimTriagingAboutTitile))
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
