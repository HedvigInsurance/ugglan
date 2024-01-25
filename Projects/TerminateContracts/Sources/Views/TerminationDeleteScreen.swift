import SwiftUI
import hCore
import hCoreUI

struct TerminationDeleteScreen: View {
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
                description: L10n.terminateContractDeletionText(
                    termination.config?.activeFrom?.localDateToDate?.displayDateDDMMMYYYYFormat ?? ""
                ),
                icon: .triangle,
                buttons: .init(
                    actionButton: nil,
                    actionButtonAttachedToBottom: .init(
                        buttonTitle: L10n.terminateContractDeletionContinueButton,
                        buttonAction: {
                            onSelected()
                            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                                self.isHidden = true
                            }
                        }
                    ),
                    dismissButton: .init(
                        buttonTitle: L10n.generalCancelButton,
                        buttonAction: {
                            store.send(.dismissTerminationFlow)
                        }
                    )
                )
            )
        }
        .hide($isHidden)

    }
}

struct TerminationDeleteScreen_Previews: PreviewProvider {
    static var previews: some View {
        TerminationDeleteScreen(onSelected: {})
    }
}
