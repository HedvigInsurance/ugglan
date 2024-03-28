import SwiftUI
import hCore
import hCoreUI

struct ConfirmTerminationScreen: View {
    @PresentableStore var store: TerminationContractStore
    @State private var isHidden = false
    let onSelected: () -> Void

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
        } _: { termination in
            GenericErrorView(
                title: L10n.General.areYouSure,
                description: terminationText(termination: termination),
                icon: .triangle,
                buttons: .init(
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
                            store.send(.goBack)
                        }
                    )
                )
            )
            .hWithLargeIcon
        }
        .hDisableScroll
        .hide($isHidden)

    }

    func terminationText(termination: TerminationContractState?) -> String {
        if termination?.config?.isDeletion ?? false {
            return L10n.terminationFlowConfirmationSubtitleDeletion
        }
        return L10n.terminationFlowConfirmationSubtitleTermination(
            termination?.terminationDateStep?.date?.displayDateDDMMMYYYYFormat ?? ""
        )
    }
}

struct TerminationDeleteScreen_Previews: PreviewProvider {
    static var previews: some View {
        ConfirmTerminationScreen(onSelected: {})
    }
}
