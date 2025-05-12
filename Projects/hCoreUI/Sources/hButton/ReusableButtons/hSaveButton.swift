import SwiftUI
import hCore

public struct hSaveButton: View {
    let action: () -> Void

    public init(
        _ action: @escaping () -> Void
    ) {
        self.action = action
    }

    public var body: some View {
        hButton(
            .large,
            .ghost,
            buttonContent: .init(title: L10n.generalSaveButton),
            { action() }
        )
    }
}
