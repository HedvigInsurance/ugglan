import SwiftUI
import hCore

public struct hContinueButton: View {
    let action: @MainActor () async -> Void

    public init(
        _ action: @escaping @MainActor () async -> Void
    ) {
        self.action = action
    }

    public var body: some View {
        hButton(
            .large,
            .primary,
            content: .init(title: L10n.generalContinueButton)
        ) { await action() }
    }
}
