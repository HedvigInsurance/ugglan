import SwiftUI

public struct DropdownView: View {
    private var value: String
    private var placeHolder: String
    private var onTap: () -> Void
    @Environment(\.isEnabled) var isEnabled
    @Environment(\.hBackgroundOption) var backgroundOption

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
                    .foregroundColor(imageColor)
                    .frame(width: 24, height: 24)
            }
        }
        .hAnimateField(false)
    }

    @hColorBuilder
    var imageColor: some hColor {
        if isEnabled, !backgroundOption.contains(.locked) {
            hFillColor.Opaque.primary
        } else {
            hFillColor.Opaque.disabled
        }
    }
}

#Preview {
    VStack {
        DropdownView(value: "", placeHolder: "placeholder", onTap: {}).hFieldSize(.small)
        DropdownView(value: "", placeHolder: "placeholder", onTap: {}).hFieldSize(.medium)
        DropdownView(value: "", placeHolder: "placeholder", onTap: {}).hFieldSize(.large)
    }
}
