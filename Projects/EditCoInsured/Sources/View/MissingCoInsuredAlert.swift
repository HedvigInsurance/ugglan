import SwiftUI
import hCore
import hCoreUI

public struct MissingCoInsuredAlert: View {
    @EnvironmentObject var router: NavigationRouter
    private var onButtonAction: () -> Void
    let config: StakeHoldersConfig
    public init(
        config: StakeHoldersConfig,
        onButtonAction: @escaping () -> Void
    ) {
        self.config = config
        self.onButtonAction = onButtonAction
    }

    public var body: some View {
        GenericErrorView(
            title: config.contractDisplayName,
            description: config.stakeHolderType.missingInformationLabel,
            formPosition: .compact
        )
        .hStateViewButtonConfig(
            .init(
                actionButtonAttachedToBottom:
                    .init(
                        buttonTitle: config.stakeHolderType.missingAddInfo,
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
            stakeHolders: [],
            contractId: "id",
            activeFrom: nil,
            numberOfMissingStakeHolders: 1,
            numberOfMissingStakeHoldersWithoutTermination: 1,
            displayName: "Display name",
            exposureDisplayName: nil,
            preSelectedStakeHolders: [],
            contractDisplayName: "Contract display name",
            holderFirstName: "Fist name",
            holderLastName: "Last name",
            holderSSN: nil,
            fromInfoCard: false,
            stakeHolderType: .coInsured
        ),
        onButtonAction: {}
    )
}
