import SwiftUI
import hCore

/// Belongs in a `.sectionContainerStyle(.transparent)` section — anything else draws a second
/// card behind it.
public struct hRadioOptionList<Content: View>: View {
    @Environment(\.hFieldSize) private var fieldSize

    private let label: String?
    private let axis: hRadioOptionListAxis
    private let spacing: CGFloat
    private let content: Content

    public init(
        label: String? = nil,
        axis: hRadioOptionListAxis = .vertical,
        spacing: CGFloat = 0,
        @RowViewBuilder content: () -> Content
    ) {
        self.label = label
        self.axis = axis
        self.spacing = spacing
        self.content = content()
    }

    public var body: some View {
        card
            .frame(maxWidth: .infinity, alignment: .leading)
            .environment(\.hRadioOptionListAxis, axis)
            .environment(\.hRadioOptionListSpacing, spacing)
            .dividerInsets(.all, 0)
    }

    @ViewBuilder
    private var card: some View {
        if isSpaced {
            labelledOptions
        } else {
            labelledOptions
                .padding(.bottom, axis == .vertical ? .padding2 : 0)
                .background(hSurfaceColor.Translucent.primary)
                .clipShape(RoundedRectangle(cornerRadius: .cornerRadiusL))
        }
    }

    private var labelledOptions: some View {
        VStack(alignment: .leading, spacing: spacing) {
            if let label {
                hText(label, style: .label)
                    .foregroundColor(hTextColor.Translucent.secondary)
                    .padding(.top, isSpaced ? 0 : metrics.labelTopPadding)
                    .padding(.horizontal, metrics.horizontalPadding)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .accessibilityAddTraits(.isHeader)
            }
            options
        }
    }

    @ViewBuilder
    private var options: some View {
        switch axis {
        case .vertical:
            VStack(spacing: spacing) {
                content
            }
        case .horizontal:
            HStack(spacing: spacing) {
                content
            }
            .hRadioIndicatorPlacement(.leading)
        }
    }

    private var metrics: hRadioOptionMetrics {
        .init(fieldSize)
    }

    private var isSpaced: Bool {
        spacing > 0
    }
}

private struct hRadioOptionListElement: Identifiable {
    let id: AnyHashable
    let hasContentBelow: Bool
    let content: AnyView
}

extension hRadioOptionList where Content == AnyView {
    /// `RowViewBuilder` can only tell which option is last when they are written out one by
    /// one, so this sets `hasContentBelow` per element instead of relying on a `ForEach`.
    public init<Element, ID: Hashable, RowContent: View>(
        _ data: [Element],
        id: KeyPath<Element, ID>,
        label: String? = nil,
        axis: hRadioOptionListAxis = .vertical,
        spacing: CGFloat = 0,
        @ViewBuilder row: (Element) -> RowContent
    ) {
        let elements: [hRadioOptionListElement] = data.enumerated()
            .map { index, element in
                .init(
                    id: element[keyPath: id],
                    hasContentBelow: index < data.count - 1,
                    content: AnyView(row(element))
                )
            }

        self.init(label: label, axis: axis, spacing: spacing) {
            AnyView(
                ForEach(elements) { element in
                    element.content
                        .environment(\.hasContentBelow, element.hasContentBelow)
                }
            )
        }
    }

    public init<Element: Identifiable, RowContent: View>(
        _ data: [Element],
        label: String? = nil,
        axis: hRadioOptionListAxis = .vertical,
        spacing: CGFloat = 0,
        @ViewBuilder row: (Element) -> RowContent
    ) {
        self.init(data, id: \.id, label: label, axis: axis, spacing: spacing, row: row)
    }
}

@available(iOS 17.0, *)
#Preview("List types") {
    @Previewable @State var selection: String? = "first"

    return ScrollView {
        VStack(spacing: .padding24) {
            hRadioOptionList(axis: .horizontal) {
                hRadioOption(value: "first", selection: $selection, item: .init(title: "Yes"))
                hRadioOption(value: "second", selection: $selection, item: .init(title: "No"))
            }

            hRadioOptionList(label: "Label", axis: .horizontal) {
                hRadioOption(value: "first", selection: $selection, item: .init(title: "Yes"))
                hRadioOption(value: "second", selection: $selection, item: .init(title: "No"))
            }

            hRadioOptionList {
                hRadioOption(value: "first", selection: $selection, item: .init(title: "Option"))
                hRadioOption(value: "second", selection: $selection, item: .init(title: "Option"))
                hRadioOption(value: "third", selection: $selection, item: .init(title: "Option"))
            }

            hRadioOptionList(label: "Label") {
                hRadioOption(value: "first", selection: $selection, item: .init(title: "Option"))
                hRadioOption(value: "second", selection: $selection, item: .init(title: "Option"))
                hRadioOption(value: "third", selection: $selection, item: .init(title: "Option"))
            }

            hRadioOptionList(label: "Spaced", spacing: .padding4) {
                hRadioOption(value: "first", selection: $selection, item: .init(title: "Option"))
                hRadioOption(value: "second", selection: $selection, item: .init(title: "Option"))
                hRadioOption(value: "third", selection: $selection, item: .init(title: "Option"))
            }

            hRadioOptionList(["first", "second", "third"], id: \.self, label: "From a collection") {
                option in
                hRadioOption(value: option, selection: $selection, item: .init(title: option.capitalized))
            }
        }
        .padding(.padding16)
        .hFieldSize(.large)
    }
}

@available(iOS 17.0, *)
#Preview("List sizes") {
    @Previewable @State var selection: String? = "first"

    return ScrollView {
        VStack(spacing: .padding24) {
            hRadioOptionList(label: "large") {
                hRadioOption(value: "first", selection: $selection, item: .init(title: "Option"))
                hRadioOption(value: "second", selection: $selection, item: .init(title: "Option"))
            }
            .hFieldSize(.large)

            hRadioOptionList(label: "medium") {
                hRadioOption(value: "first", selection: $selection, item: .init(title: "Option"))
                hRadioOption(value: "second", selection: $selection, item: .init(title: "Option"))
            }
            .hFieldSize(.medium)

            hRadioOptionList(label: "small") {
                hRadioOption(value: "first", selection: $selection, item: .init(title: "Option"))
                hRadioOption(value: "second", selection: $selection, item: .init(title: "Option"))
            }
            .hFieldSize(.small)
        }
        .padding(.padding16)
    }
}
