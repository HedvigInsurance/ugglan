import SwiftUI
import hCore
import hCoreUI

public struct MissingStakeholderAlert: View {
    @EnvironmentObject var router: Router
    private var onButtonAction: () -> Void
    let config: StakeholdersConfig
    public init(
        config: StakeholdersConfig,
        onButtonAction: @escaping () -> Void
    ) {
        self.config = config
        self.onButtonAction = onButtonAction
    }

    public var body: some View {
        GenericErrorView(
            title: config.contractDisplayName,
            description: config.stakeholderType.missingInformationLabel,
            formPosition: .compact
        )
        .hStateViewButtonConfig(
            .init(
                actionButtonAttachedToBottom:
                    .init(
                        buttonTitle: config.stakeholderType.missingAddInfo,
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
    MissingStakeholderAlert(
        config: .init(
            id: UUID().uuidString,
            stakeholders: [],
            contractId: "id",
            activeFrom: nil,
            numberOfMissingStakeholders: 1,
            numberOfMissingStakeholdersWithoutTermination: 1,
            displayName: "Display name",
            exposureDisplayName: nil,
            preSelectedStakeholders: [],
            contractDisplayName: "Contract display name",
            holderFirstName: "Fist name",
            holderLastName: "Last name",
            holderSSN: nil,
            fromInfoCard: false,
            stakeholderType: .coInsured
        ),
        onButtonAction: {}
    )
}
