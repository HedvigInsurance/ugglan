import SwiftUI
import hCore

public struct hRadioOption<Value>: View where Value: Hashable {
    @Environment(\.hFieldSize) private var fieldSize
    @Environment(\.hRadioIndicatorPlacement) private var placement
    @Environment(\.hRadioOptionListAxis) private var listAxis
    @Environment(\.hRadioOptionListSpacing) private var listSpacing
    @Environment(\.hasContentBelow) private var hasContentBelow
    @Environment(\.isEnabled) private var isEnabled

    private let value: Value?
    @Binding private var selection: Value?
    private let content: OptionContent
    private let accessory: hRadioOptionAccessory
    private let trailing: AnyView?
    private let onTap: (() -> Void)?

    private enum OptionContent {
        case item(ItemModel, leading: AnyView?, highlight: String?)
        case custom(AnyView)
    }

    public init(
        value: Value,
        selection: Binding<Value?>,
        item: ItemModel,
        highlight: String? = nil
    ) {
        self.init(
            value: value,
            selection: selection,
            content: .item(item, leading: nil, highlight: highlight),
            accessory: .radio
        )
    }

    public init<Leading: View>(
        value: Value,
        selection: Binding<Value?>,
        item: ItemModel,
        highlight: String? = nil,
        @ViewBuilder leading: () -> Leading
    ) {
        self.init(
            value: value,
            selection: selection,
            content: .item(item, leading: AnyView(leading()), highlight: highlight),
            accessory: .radio
        )
    }

    public init<CustomContent: View>(
        value: Value,
        selection: Binding<Value?>,
        @ViewBuilder content: () -> CustomContent
    ) {
        self.init(
            value: value,
            selection: selection,
            content: .custom(AnyView(content())),
            accessory: .radio
        )
    }

    private init(
        value: Value?,
        selection: Binding<Value?>,
        content: OptionContent,
        accessory: hRadioOptionAccessory,
        trailing: AnyView? = nil,
        onTap: (() -> Void)? = nil
    ) {
        self.value = value
        _selection = selection
        self.content = content
        self.accessory = accessory
        self.trailing = trailing
        self.onTap = onTap
    }

    public var body: some View {
        VStack(spacing: 0) {
            row
            if listAxis == .vertical, listSpacing == 0, hasContentBelow {
                hRowDivider()
            }
        }
    }

    private var row: some View {
        rowContent
            .padding(.top, topVerticalPadding)
            .padding(.bottom, bottomVerticalPadding)
            .padding(.leading, metrics.leadingPadding(hasIcon: hasLeadingIcon))
            .padding(.trailing, metrics.horizontalPadding)
            .frame(maxWidth: .infinity, minHeight: metrics.minHeight, alignment: .leading)
            .background(backgroundColor)
            .clipShape(RoundedRectangle(cornerRadius: isGrouped ? 0 : .cornerRadiusL))
            .contentShape(Rectangle())
            .onTapGesture(perform: activate)
            .accessibilityElement(children: .combine)
            .accessibilityAddTraits(.isButton)
            .accessibilityAddTraits(isSelected ? .isSelected : [])
            .accessibilityValue(selectionAccessibilityValue)
    }

    @ViewBuilder
    private var rowContent: some View {
        HStack(spacing: metrics.spacing) {
            if placement == .leading {
                accessoryView
            }

            switch content {
            case let .item(item, leading, highlight):
                if let leading {
                    leading
                        .frame(width: metrics.iconSize, height: metrics.iconSize)
                        .opacity(isEnabled ? 1 : 0.4)
                        .accessibilityHidden(true)
                }
                textContent(for: item, highlight: highlight)
            case let .custom(view):
                view
                    .frame(maxWidth: .infinity, alignment: .leading)
            }

            if let trailing {
                trailing
            }

            if placement == .trailing {
                accessoryView
            }
        }
    }

    @ViewBuilder
    private var accessoryView: some View {
        switch accessory {
        case .radio:
            hRadioIndicator(isSelected: isSelected)
        case .chevron:
            StandaloneChevronAccessory()
        case .none:
            EmptyView()
        }
    }

    private func textContent(for item: ItemModel, highlight: String?) -> some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack(spacing: metrics.spacing) {
                hText(item.title, style: metrics.titleStyle)
                    .foregroundColor(titleColor)
                    .frame(maxWidth: .infinity, alignment: .leading)
                if let highlight {
                    hRadioOptionHighlight(text: highlight)
                }
            }
            if let subTitle = item.subTitle {
                hText(subTitle, style: .label)
                    .foregroundColor(subTitleColor)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
    }

    private func activate() {
        guard isEnabled else { return }
        ImpactGenerator.soft()
        if let onTap {
            onTap()
        } else if let value {
            selection = value
        }
    }

    /// A navigation row is a plain button — announcing it as "not selected" would be a lie.
    private var selectionAccessibilityValue: String {
        guard accessory == .radio, !isSelected else { return "" }
        return L10n.a11YOptionNotSelected
    }

    private var metrics: hRadioOptionMetrics {
        .init(fieldSize)
    }

    private var isSelected: Bool {
        guard let value else { return false }
        return selection == value
    }

    private var isGrouped: Bool {
        listAxis != nil && listSpacing == 0
    }

    private var hasLeadingIcon: Bool {
        if case let .item(_, leading, _) = content {
            return leading != nil
        }
        return false
    }

    private var topVerticalPadding: CGFloat {
        hasLeadingIcon ? metrics.iconVerticalPadding : metrics.topPadding
    }

    private var bottomVerticalPadding: CGFloat {
        hasLeadingIcon ? metrics.iconVerticalPadding : metrics.bottomPadding
    }

    @hColorBuilder
    private var backgroundColor: some hColor {
        if isGrouped {
            hBackgroundColor.clear
        } else {
            hSurfaceColor.Translucent.primary
        }
    }

    @hColorBuilder
    private var titleColor: some hColor {
        if isEnabled {
            hTextColor.Opaque.primary
        } else {
            hTextColor.Translucent.disabled
        }
    }

    @hColorBuilder
    private var subTitleColor: some hColor {
        if isEnabled {
            hTextColor.Translucent.secondary
        } else {
            hTextColor.Translucent.disabled
        }
    }
}

extension hRadioOption where Value == Never {
    public init<Leading: View>(
        item: ItemModel,
        highlight: String? = nil,
        accessory: hRadioOptionAccessory = .chevron,
        onTap: @escaping () -> Void,
        @ViewBuilder leading: () -> Leading
    ) {
        self.init(
            value: nil,
            selection: .constant(nil),
            content: .item(item, leading: AnyView(leading()), highlight: highlight),
            accessory: accessory,
            onTap: onTap
        )
    }

    public init<Trailing: View, Leading: View>(
        item: ItemModel,
        highlight: String? = nil,
        accessory: hRadioOptionAccessory = .chevron,
        onTap: @escaping () -> Void,
        @ViewBuilder trailing: () -> Trailing,
        @ViewBuilder leading: () -> Leading
    ) {
        self.init(
            value: nil,
            selection: .constant(nil),
            content: .item(item, leading: AnyView(leading()), highlight: highlight),
            accessory: accessory,
            trailing: AnyView(trailing()),
            onTap: onTap
        )
    }
}

private struct hRadioOptionHighlight: View {
    @Environment(\.isEnabled) private var isEnabled

    let text: String

    var body: some View {
        hText(text, style: .label)
            .foregroundColor(textColor)
            .fixedSize()
            .padding(.horizontal, .padding6)
            .padding(.vertical, .padding3)
            .background(hSurfaceColor.Translucent.primary)
            .clipShape(RoundedRectangle(cornerRadius: .cornerRadiusXS))
    }

    @hColorBuilder
    private var textColor: some hColor {
        if isEnabled {
            hTextColor.Opaque.primary
        } else {
            hTextColor.Translucent.disabled
        }
    }
}

private struct hRadioOptionMatrixColumn: View {
    let size: hFieldSize
    let title: String
    @Binding var selection: String?

    var body: some View {
        VStack(alignment: .leading, spacing: .padding4) {
            hText(title, style: .finePrint)
                .foregroundColor(hTextColor.Translucent.secondary)

            hRadioOption(value: "resting", selection: $selection, item: .init(title: "Option"))
            hRadioOption(value: "selected", selection: $selection, item: .init(title: "Option"))
            hRadioOption(value: "disabled", selection: $selection, item: .init(title: "Option"))
                .disabled(true)

            hRadioOption(
                value: "label",
                selection: $selection,
                item: .init(title: "Label", subTitle: "920321412")
            )
            hRadioOption(value: "icon", selection: $selection, item: .init(title: "Option")) {
                hCoreUIAssets.pillowHome.view.resizable()
            }
            hRadioOption(value: "leading", selection: $selection, item: .init(title: "Option"))
                .hRadioIndicatorPlacement(.leading)
            hRadioOption(
                value: "highlight",
                selection: $selection,
                item: .init(title: "Option"),
                highlight: "+ 50 kr/mo"
            )
        }
        .hFieldSize(size)
    }
}

@available(iOS 17.0, *)
#Preview("Types and states") {
    @Previewable @State var selection: String? = "selected"

    return ScrollView {
        VStack(spacing: .padding24) {
            hRadioOptionMatrixColumn(size: .large, title: "large", selection: $selection)
            hRadioOptionMatrixColumn(size: .medium, title: "medium", selection: $selection)
            hRadioOptionMatrixColumn(size: .small, title: "small", selection: $selection)
        }
        .padding(.padding16)
    }
}
