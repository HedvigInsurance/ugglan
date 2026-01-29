import SwiftUI
import hCore

public struct hCancelButton: View {
    let action: () -> Void
    let type: hButtonConfigurationType

    public init(
        type: hButtonConfigurationType? = .ghost,
        _ action: @escaping () -> Void
    ) {
        self.type = type ?? .ghost
        self.action = action
    }

    public var body: some View {
        hButton(
            .large,
            type,
            content: .init(title: L10n.generalCancelButton),
            { action() }
        )
    }
}
