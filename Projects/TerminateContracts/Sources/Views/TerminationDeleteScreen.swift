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

            PresentableStoreLens(
                TerminationContractStore.self
            ) { state in
                state
            } _: { termination in
                GenericErrorView(
                    title: L10n.General.areYouSure,
                    description: "The selected insurance will be deleted which means it will not be activated on "
                        + (termination.config?.activeFrom?.localDateToDate?.displayDateDDMMMYYYYFormat ?? ""),
                    icon: .triangle,
                    buttons: .init(
                        actionButton: nil,
                        actionButtonAttachedToBottom: .init(
                            buttonTitle: "Yes, continue",
                            buttonAction: {
                                onSelected()
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
        }
    }
}

struct TerminationDeleteScreen_Previews: PreviewProvider {
    static var previews: some View {
        TerminationDeleteScreen(onSelected: {})
    }
}
