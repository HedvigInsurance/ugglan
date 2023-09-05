import SwiftUI
import hCore
import hCoreUI

struct TerminationDeleteScreen: View {
    @PresentableStore var store: TerminationContractStore
    let onSelected: () -> Void

    init(
        onSelected: @escaping () -> Void
    ) {
        self.onSelected = onSelected
    }

    var body: some View {
        LoadingViewWithContent(TerminationContractStore.self, [.deleteTermination], [.deleteTermination]) {
            hForm {
                PresentableStoreLens(
                    TerminationContractStore.self,
                    getter: { state in
                        state.terminationDeleteStep
                    }
                ) { termination in

                    VStack(spacing: 8) {
                        Image(uiImage: hCoreUIAssets.warningTriangle.image)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.vertical, 4)

                        PresentableStoreLens(
                            TerminationContractStore.self
                        ) { state in
                            state.terminationContractId ?? ""
                        } _: { value in

                            PresentableStoreLens(
                                TerminationContractStore.self
                            ) { state in
                                state.contractName
                            } _: { name in
                                hText(
                                    L10n.terminationContractDeletionAlertDescription(name ?? ""),
                                    style: .title2
                                )
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding(.bottom, 4)
                            }
                        }

                        hText(termination?.disclaimer ?? "", style: .body)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    .padding(.leading, 16)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)

            .hFormAttachToBottom {

                VStack {
                    hButton.LargeButtonOutlined {
                        store.send(.dismissTerminationFlow)
                    } content: {
                        hText(L10n.generalCloseButton, style: .body)
                            .foregroundColor(hLabelColor.primary)
                    }
                    .padding(.bottom, 4)
                    hButton.LargeButtonPrimary {
                        onSelected()
                    } content: {
                        hText(L10n.terminationContractDeletionConfirmButton, style: .body)
                            .foregroundColor(hLabelColor.primary.inverted)
                    }
                    .padding(.bottom, 2)
                }
                .padding([.leading, .trailing, .bottom], 16)
            }
        }
    }
}

struct TerminationDeleteScreen_Previews: PreviewProvider {
    static var previews: some View {
        TerminationFailScreen()
    }
}
