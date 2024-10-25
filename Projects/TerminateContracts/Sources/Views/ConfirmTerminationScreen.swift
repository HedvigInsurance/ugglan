import PresentableStore
import SwiftUI
import hCore
import hCoreUI

struct ConfirmTerminationScreen: View {
    @State private var isHidden = false
    let onSelected: () -> Void
    @EnvironmentObject var terminationNavigationVm: TerminationFlowNavigationViewModel

    init(
        onSelected: @escaping () -> Void
    ) {
        self.onSelected = onSelected
    }

    var body: some View {
        PresentableStoreLens(
            TerminationContractStore.self
        ) { state in
            state
        } _: { state in
            GenericErrorView(
                title: L10n.General.areYouSure,
                description: terminationText(state: state),
                attachContentToTheBottom: true
            )
            .hErrorViewButtonConfig(
                .init(
                    actionButtonAttachedToBottom:
                        .init(
                            buttonTitle: L10n.terminationFlowConfirmButton,
                            buttonAction: {
                                onSelected()
                                DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                                    self.isHidden = true
                                }
                            }
                        ),
                    dismissButton: .init(
                        buttonTitle: L10n.generalCloseButton,
                        buttonAction: {
                            terminationNavigationVm.isConfirmTerminationPresented = false
                        }
                    )
                )
            )
            .hExtraTopPadding
        }
        .hDisableScroll
        .hide($isHidden)

    }

    func terminationText(state: TerminationContractState) -> String {
        if state.isDeletion {
            return L10n.terminationFlowConfirmation
        }
        return L10n.terminationFlowConfirmationSubtitleTermination(
            state.terminationDateStep?.date?.displayDateDDMMMYYYYFormat ?? ""
        )
    }
}

struct TerminationDeleteScreen_Previews: PreviewProvider {
    static var previews: some View {
        ConfirmTerminationScreen(onSelected: {})
    }
}
