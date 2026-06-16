import Foundation
import SwiftUI
import hCore
import hCoreUI

public struct ConnectPayoutCardView: View {
    let onTap: @MainActor @Sendable () -> Void
    public init(onTap: @MainActor @Sendable @escaping () -> Void) {
        self.onTap = onTap
    }
    public var body: some View {
        InfoCard(
            text: L10n.payoutMissingInfo,
            type: .attention
        )
        .buttons(
            [
                .init(
                    buttonTitle: L10n.payoutAddPayoutMethod,
                    buttonAction: onTap
                )
            ]
        )
    }
}
