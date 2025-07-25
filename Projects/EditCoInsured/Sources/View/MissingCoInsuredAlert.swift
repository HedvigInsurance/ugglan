import EditCoInsured
import SwiftUI
import hCore
import hCoreUI

public struct MissingCoInsuredAlert: View {
    @EnvironmentObject var router: Router
    private var onButtonAction: () -> Void
    let config: InsuredPeopleConfig
    public init(
        config: InsuredPeopleConfig,
        onButtonAction: @escaping () -> Void
    ) {
        self.config = config
        self.onButtonAction = onButtonAction
    }

    public var body: some View {
        GenericErrorView(
            title: config.contractDisplayName,
            description: L10n.contractCoinsuredMissingInformationLabel,
            formPosition: .compact
        )
        .hStateViewButtonConfig(
            .init(
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
    }
}

#Preview {
    MissingCoInsuredAlert(
        config: .init(
            id: UUID().uuidString,
            contractCoInsured: [],
            contractId: "id",
            activeFrom: nil,
            numberOfMissingCoInsured: 1,
            numberOfMissingCoInsuredWithoutTermination: 1,
            displayName: "Display name",
            exposureDisplayName: nil,
            preSelectedCoInsuredList: [],
            contractDisplayName: "Contract display name",
            holderFirstName: "Fist name",
            holderLastName: "Last name",
            holderSSN: nil,
            fromInfoCard: false
        ),
        onButtonAction: {}
    )
}
