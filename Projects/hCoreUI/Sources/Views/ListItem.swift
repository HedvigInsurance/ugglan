import SwiftUI

public struct ListItem: View {
    let title: String
    let onClick: () -> Void
    @Environment(\.hListStyle) var style

    public init(
        title: String,
        onClick: @escaping () -> Void
    ) {
        self.title = title
        self.onClick = onClick
    }

    public var body: some View {
        if style == .chevron {
            hRow {
                hText(title, style: .title3)
                    .foregroundColor(hTextColor.Opaque.primary)
                Spacer()
            }
            .withChevronAccessory
            .verticalPadding(9)
            .onTap {
                onClick()
            }
            .foregroundColor(hTextColor.Opaque.tertiary)
        } else {
            hRow {
                hText(title, style: .title3)
                    .foregroundColor(hTextColor.Opaque.primary)
                Spacer()
            }
            .withCustomAccessory {
                if style == .radioOption {
                    hRadioOptionSelectedView(
                        selectedValue: .constant("value"),
                        value: "valuee"
                    )
                } else {
                    hRadioOptionSelectedView(
                        selectedValue: .constant("value"),
                        value: "valuee"
                    )
                    .hUseCheckbox
                }
            }
            .verticalPadding(9)
            .onTap {
                onClick()
            }
            .foregroundColor(hTextColor.Opaque.tertiary)
        }
    }
}

public enum ListStyle {
    case chevron
    case radioOption
    case checkBox
}

private struct EnvironmentHListStyle: EnvironmentKey {
    static let defaultValue: ListStyle = .chevron
}

extension EnvironmentValues {
    public var hListStyle: ListStyle {
        get { self[EnvironmentHListStyle.self] }
        set { self[EnvironmentHListStyle.self] = newValue }
    }
}

extension View {
    public func hListStyle(_ style: ListStyle) -> some View {
        self.environment(\.hListStyle, style)
    }
}

#Preview{
    hSection {
        ListItem(title: "", onClick: {}).hListStyle(.chevron)
        ListItem(title: "", onClick: {}).hListStyle(.checkBox)
        ListItem(title: "", onClick: {}).hListStyle(.radioOption)
    }
}
