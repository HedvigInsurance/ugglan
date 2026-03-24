import EditStakeholders
import SwiftUI
import hCore
import hCoreUI

public struct StakeholderInfoHomeView: View {
    let infoText: String
    let onTapAction: () -> Void

    public init(
        infoText: String,
        onTapAction: @escaping () -> Void,
    ) {
        self.infoText = infoText
        self.onTapAction = onTapAction
    }

    public var body: some View {
        InfoCard(text: infoText, type: .attention)
            .buttons([
                .init(
                    buttonTitle: L10n.contractCoinsuredMissingAddInfo,
                    buttonAction: { onTapAction() }
                )
            ])
    }
}
