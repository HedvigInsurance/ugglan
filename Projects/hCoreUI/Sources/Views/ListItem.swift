import SwiftUI

public struct ListItems<T>: View {
    @Environment(\.hListRowStyle) var rowStyle
    let onClick: (T) -> Void
    var items: [(object: T, displayName: String)]

    public init(
        onClick: @escaping (T) -> Void,
        items: [(object: T, displayName: String)]
    ) {
        self.onClick = onClick
        self.items = items
    }

    public var body: some View {
        if rowStyle == .standard {
            hSection(items, id: \.displayName) { item in
                ListItem(
                    title: item.displayName,
                    onClick: {
                        onClick(item.object)
                    }
                )
            }
            .sectionContainerStyle(.transparent)
        } else {
            VStack(spacing: 4) {
                ForEach(items, id: \.displayName) { item in
                    hSection {
                        ListItem(
                            title: item.displayName,
                            onClick: {
                                onClick(item.object)
                            }
                        )
                    }
                }
            }
        }
    }
}

public struct ListItem: View {
    let title: String
    let onClick: () -> Void
    @Environment(\.hListStyle) var style
    @Environment(\.hListRowStyle) var rowStyle
    @Environment(\.hFieldSize) var fieldSize
    @State var isSelected = false

    public init(
        title: String,
        onClick: @escaping () -> Void
    ) {
        self.title = title
        self.onClick = onClick
    }

    public var body: some View {
        Group {
            if style == .chevron {
                hRow {
                    getMainContent
                }
                .withChevronAccessory
                .verticalPadding(rowStyle == .filled ? 0 : 16)
                .topPadding(rowStyle == .filled ? getTopPadding : 0)
                .bottomPadding(rowStyle == .filled ? getBottomPadding : 0)
                .onTap {
                    onClick()
                }
            } else {
                hRow {
                    getMainContent
                }
                .verticalPadding(rowStyle == .filled ? 0 : 16)
                .topPadding(rowStyle == .filled ? getTopPadding : 0)
                .bottomPadding(rowStyle == .filled ? getBottomPadding : 0)
                .withCustomAccessory {
                    if style == .radioOption {
                        getRadioField
                    } else {
                        getRadioField
                            .hUseCheckbox
                    }
                }
                .onTap {
                    onClick()
                }
            }
        }
        .foregroundColor(hTextColor.Opaque.tertiary)
    }

    @ViewBuilder
    private var getMainContent: some View {
        hText(title, style: .heading2)
            .fixedSize()
            .foregroundColor(hTextColor.Opaque.primary)
        Spacer()
    }

    @ViewBuilder
    private var getRadioField: some View {
        hRadioOptionSelectedView(
            selectedValue: .constant(isSelected ? title : nil),
            value: title
        )
        .onTapGesture {
            if isSelected {
                isSelected = false
            } else {
                isSelected = true
            }
        }
    }

    private var getTopPadding: CGFloat {
        if fieldSize == .large {
            return 12.5
        } else {
            return 15
        }
    }

    private var getBottomPadding: CGFloat {
        if fieldSize == .large {
            return 13.5
        } else {
            return 17
        }
    }
}

public enum ListStyle: Sendable {
    case chevron
    case radioOption
    case checkBox
}

public enum ListRowStyle: Sendable {
    case standard
    case filled
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

private struct EnvironmentHListRowStyle: EnvironmentKey {
    static let defaultValue: ListRowStyle = .standard
}

extension EnvironmentValues {
    public var hListRowStyle: ListRowStyle {
        get { self[EnvironmentHListRowStyle.self] }
        set { self[EnvironmentHListRowStyle.self] = newValue }
    }
}

extension View {
    public func hListRowStyle(_ style: ListRowStyle) -> some View {
        self.environment(\.hListRowStyle, style)
    }
}

struct ListWithItems_Previews: PreviewProvider {
    struct ModelForPreview: Hashable {
        let id: String
        let name: String
    }

    static var previews: some View {
        VStack(spacing: 0) {
            ListItems<ModelForPreview>(
                onClick: { item in },
                items: [
                    (object: .init(id: "id1", name: "Label"), displayName: "Label"),
                    (object: .init(id: "id2", name: "Label"), displayName: "Label"),
                    (object: .init(id: "id3", name: "Label"), displayName: "Label"),
                    (object: .init(id: "id4", name: "Label"), displayName: "Label"),
                    (object: .init(id: "id5", name: "Label"), displayName: "Label"),
                ]
            )

            ListItems<ModelForPreview>(
                onClick: { item in },
                items: [
                    (object: .init(id: "id1", name: "Label"), displayName: "Label"),
                    (object: .init(id: "id2", name: "Label"), displayName: "Label"),
                    (object: .init(id: "id3", name: "Label"), displayName: "Label"),
                    (object: .init(id: "id4", name: "Label"), displayName: "Label"),
                    (object: .init(id: "id5", name: "Label"), displayName: "Label"),
                ]
            )
            .hListRowStyle(.filled)
        }
    }
}

struct Item_Previews: PreviewProvider {
    struct ModelForPreview {
        let id: String
        let name: String
    }

    static var previews: some View {
        HStack {
            VStack {
                hSection {
                    ListItem(title: "label", onClick: {})
                        .hListStyle(.chevron)
                }
                hSection {
                    ListItem(title: "label", onClick: {})
                        .hListStyle(.radioOption)
                }
                hSection {
                    ListItem(title: "label", onClick: {})
                        .hListStyle(.checkBox)
                }
            }
            .hFieldSize(.large)

            VStack {
                hSection {
                    ListItem(title: "label", onClick: {})
                        .hListStyle(.chevron)
                }
                hSection {
                    ListItem(title: "label", onClick: {})
                        .hListStyle(.radioOption)
                }
                hSection {
                    ListItem(title: "label", onClick: {})
                        .hListStyle(.checkBox)
                }
            }
            .hFieldSize(.medium)

            VStack {
                hSection {
                    ListItem(title: "label", onClick: {})
                        .hListStyle(.chevron)
                }
                hSection {
                    ListItem(title: "label", onClick: {})
                        .hListStyle(.radioOption)
                }
                hSection {
                    ListItem(title: "label", onClick: {})
                        .hListStyle(.checkBox)
                }
            }
            .hFieldSize(.small)
        }
        .hListRowStyle(.filled)
    }
}
