import SwiftUI
import hCore

public struct hContinueButton: View {
    let action: () -> Void

    public init(
        _ action: @escaping () -> Void
    ) {
        self.action = action
    }

    public var body: some View {
        hButton(
            .large,
            .primary,
            title: L10n.generalContinueButton,
            { action() }
        )
    }
}
