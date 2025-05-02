import SwiftUI
import hCore

public struct hCloseButton: View {
    let action: () -> Void

    public init(
        _ action: @escaping () -> Void
    ) {
        self.action = action
    }

    public var body: some View {
        hButton.LargeButton(type: .ghost) {
            action()
        } content: {
            hText(L10n.generalCloseButton)
        }
    }
}
