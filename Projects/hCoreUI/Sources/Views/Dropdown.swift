import SwiftUI

public struct DropdownView: View {
    private var value: String
    private var placeHolder: String
    private var onTap: () -> Void
    @Environment(\.isEnabled) var isEnabled
    @Environment(\.hBackgroundOption) var backgroundOption
    @Binding var error: String?
    public init(
        value: String,
        placeHolder: String,
        error: Binding<String?>? = nil,
        onTap: @escaping () -> Void
    ) {
        self.value = value
        self.placeHolder = placeHolder
        self.onTap = onTap
        self._error = error ?? .constant(nil)
    }

    public var body: some View {
        hSection {
            hFloatingField(
                value: value,
                placeholder: placeHolder,
                error: $error,
                onTap: {
                    onTap()
                }
            )
            .hFieldTrailingView {
                Group {
                    if backgroundOption.contains(.locked) && !isEnabled {
                        hCoreUIAssets.lock.view
                    } else {
                        hCoreUIAssets.chevronDown.view
                    }
                }
                .foregroundColor(imageColor)
                .frame(width: 24, height: 24)
            }
        }
        .hAnimateField(false)
    }

    @hColorBuilder
    var imageColor: some hColor {
        if isEnabled {
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
