import SwiftUI
import hCore

public struct hCancelButton: View {
    let action: @MainActor () async -> Void
    let type: hButtonConfigurationType

    public init(
        _ type: hButtonConfigurationType = .ghost,
        _ action: @escaping @MainActor () async -> Void
    ) {
        self.type = type
        self.action = action
    }

    public var body: some View {
        hButton(
            .large,
            type,
            content: .init(title: L10n.generalCancelButton)
        ) { await action() }
    }
}
