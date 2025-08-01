import hCore
import SwiftUI

public struct hSaveButton: View {
    let action: () -> Void
    let type: hButtonConfigurationType

    public init(
        _ action: @escaping () -> Void,
        type: hButtonConfigurationType? = .ghost
    ) {
        self.action = action
        self.type = type ?? .ghost
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
