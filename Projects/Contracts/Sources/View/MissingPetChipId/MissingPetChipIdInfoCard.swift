import SwiftUI
import hCore
import hCoreUI

public struct MissingPetChipIdInfoCard: View {
    let action: () -> Void

    public init(action: @escaping () -> Void) {
        self.action = action
    }

    public var body: some View {
        InfoCard(text: L10n.chipIdMissingMessage, type: .attention)
            .buttons([
                .init(buttonTitle: L10n.chipIdMissingButton) { action() }
            ])
    }
}
