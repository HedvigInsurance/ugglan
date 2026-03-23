import SwiftUI
import hCore
import hCoreUI

struct ContactInfoView: View {
    var body: some View {
        InfoCard(
            text: L10n.missingContactInfoCardText,
            type: .info
        )
        .buttons(
            [
                .init(
                    buttonTitle: L10n.missingContactInfoCardButton,
                    buttonAction: { NotificationCenter.default.post(name: .openReviewContactInfo, object: nil) }
                )
            ]
        )
    }
}
