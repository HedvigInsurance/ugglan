import Claims
import SwiftUI
import hCore
import hCoreUI

public struct SubmitClaimSuccessView: View {
    private let model: ClaimIntentOutcomeClaim
    @EnvironmentObject var router: Router
    public init(
        model: ClaimIntentOutcomeClaim,
    ) {
        self.model = model
    }

    public var body: some View {
        SuccessScreen(
            title: L10n.claimsSuccessTitle,
            subtitle: L10n.claimsSuccessLabel,
            formPosition: .center
        )
        .hStateViewButtonConfig(
            .init(
                actionButtonAttachedToBottom: .init(
                    buttonTitle: L10n.generalDoneButton,
                    buttonStyle: .secondary,
                    buttonAction: {
                        router.dismiss()
                    }
                )
            )
        )
    }
}

#Preview {
    let model = ClaimIntentOutcomeClaim(
        claimId: "claimId",
        claim: .init(
            id: "id",
            status: .beingHandled,
            outcome: nil,
            submittedAt: nil,
            signedAudioURL: nil,
            memberFreeText: nil,
            payoutAmount: nil,
            targetFileUploadUri: "",
            claimType: "",
            productVariant: nil,
            conversation: nil,
            appealInstructionsUrl: nil,
            isUploadingFilesEnabled: false,
            showClaimClosedFlow: false,
            infoText: nil,
            displayItems: []
        )
    )
    return SubmitClaimSuccessView(
        model: model
    )
    .environmentObject(
        SubmitClaimChatViewModel.init(
            startInput: .init(
                input: .init(sourceMessageId: nil),
                openChat: {
                }
            )
        )
    )
}
