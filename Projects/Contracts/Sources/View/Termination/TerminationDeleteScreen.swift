import SwiftUI
import hCore
import hCoreUI

public struct TerminationDeleteScreen: View {
    @PresentableStore var store: ContractStore
    let onSelected: () -> Void

    public init(
        onSelected: @escaping () -> Void
    ) {
        self.onSelected = onSelected
    }

    public var body: some View {

        hForm {

            PresentableStoreLens(
                ContractStore.self,
                getter: { state in
                    state.terminationDeleteStep
                }
            ) { termination in

                Image(uiImage: hCoreUIAssets.warningTriangle.image)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.leading, 16)
                    .padding([.bottom, .top], 4)

                PresentableStoreLens(
                    ContractStore.self
                ) { state in
                    state.terminationContractId ?? ""
                } _: { value in

                    PresentableStoreLens(
                        ContractStore.self
                    ) { state in
                        state.contractForId(value)
                    } _: { value in

                        hText(
                            L10n.terminationContractDeletionAlertDescription("\"" + (value?.displayName ?? "") + "\""),
                            style: .title2
                        )
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.leading, 16)
                        .padding(.bottom, 4)
                    }
                }

                hText(termination?.disclaimer ?? "", style: .body)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.leading, 16)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)

        .hFormAttachToBottom {

            VStack {
                hButton.LargeButtonOutlined {
                    store.send(.dismissTerminationFlow)
                    //                    onSelected()
                } content: {
                    hText(L10n.generalCloseButton, style: .body)
                        .foregroundColor(hLabelColor.primary)
                }
                .padding(.bottom, 4)
                hButton.LargeButtonFilled {
                    //                    store.send(.)
                    onSelected()
                } content: {
                    hText(L10n.generalContinueButton, style: .body)
                        .foregroundColor(hLabelColor.primary.inverted)
                }
                .padding(.bottom, 2)
            }
            .padding([.leading, .trailing, .bottom], 16)
        }
    }
}

struct TerminationDeleteScreen_Previews: PreviewProvider {
    static var previews: some View {
        TerminationFailScreen()
    }
}
