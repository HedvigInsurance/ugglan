import SwiftUI
import hCore

public struct hCancelButton: View {
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
            L10n.generalCancelButton.hText(.body1)
                .foregroundColor(hTextColor.Opaque.primary)
        }
    }
}
