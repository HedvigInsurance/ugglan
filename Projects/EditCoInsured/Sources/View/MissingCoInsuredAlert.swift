import SwiftUI
import hCore
import hCoreUI

public struct MissingCoInsuredAlert: View {
    @PresentableStore var store: EditCoInsuredStore
    @EnvironmentObject var router: Router
    private var onButtonAction: () -> Void

    public init(
        onButtonAction: @escaping () -> Void
    ) {
        self.onButtonAction = onButtonAction
    }

    public var body: some View {
        GenericErrorView(
            title: store.coInsuredViewModel.config.contractDisplayName,
            description: L10n.contractCoinsuredMissingInformationLabel,
            buttons: .init(
                actionButtonAttachedToBottom:
                    .init(
                        buttonTitle: L10n.contractCoinsuredMissingAddInfo,
                        buttonAction: {
                            onButtonAction()
                        }
                    ),
                dismissButton:
                    .init(
                        buttonTitle: L10n.contractCoinsuredMissingLater,
                        buttonAction: {
                            router.dismiss()
                        }
                    )
            )
        )
        .hExtraBottomPadding
    }
}

#Preview{
    MissingCoInsuredAlert(onButtonAction: {})
}
