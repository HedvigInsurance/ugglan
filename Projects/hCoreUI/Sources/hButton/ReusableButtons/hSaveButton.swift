import SwiftUI
import hCore

public struct hSaveButton: View {
    let action: () -> Void
    let type: hButtonConfigurationType

    public init(
        _ type: hButtonConfigurationType = .ghost,
        _ action: @escaping () -> Void,
    ) {
        self.action = action
        self.type = type
    }

    public var body: some View {
        hButton(
            .large,
            type,
            content: .init(title: L10n.generalSaveButton),
            { action() }
        )
    }
}
