import hCore
import hCoreUI
import SwiftUI

public struct CoInsuredInfoHomeView: View {
    var onTapAction: () -> Void

    public init(
        onTapAction: @escaping () -> Void
    ) {
        self.onTapAction = onTapAction
    }

    public var body: some View {
        InfoCard(text: L10n.contractCoinsuredMissingInfoText, type: .attention)
            .buttons([
                .init(
                    buttonTitle: L10n.contractCoinsuredMissingAddInfo,
                    buttonAction: {
                        onTapAction()
                    }
                ),
            ])
    }
}
