import SwiftUI

public struct DropdownView: View {
    private var value: String
    private var placeHolder: String
    private var onTap: () -> Void

    public init(
        value: String,
        placeHolder: String,
        onTap: @escaping () -> Void
    ) {
        self.value = value
        self.placeHolder = placeHolder
        self.onTap = onTap
    }

    public var body: some View {
        hSection {
            hFloatingField(
                value: value,
                placeholder: placeHolder,
                onTap: {
                    onTap()
                }
            )
            .hFieldTrailingView {
                hCoreUIAssets.chevronDown.view
                    .foregroundColor(hFillColor.Opaque.primary)
                    .frame(width: 24, height: 24)
            }
        }
    }
}

#Preview{
    DropdownView(value: "value", placeHolder: "placeholder", onTap: {})
}
