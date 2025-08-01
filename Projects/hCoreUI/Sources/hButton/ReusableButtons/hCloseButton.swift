import hCore
import SwiftUI

public struct hCloseButton: View {
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
            content: .init(title: L10n.generalCloseButton),
            { action() }
        )
    }
}
