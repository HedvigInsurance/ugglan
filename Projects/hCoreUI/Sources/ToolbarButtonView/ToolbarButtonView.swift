import Foundation
import SwiftUI
import hCore

public struct ToolbarButtonView: View {
    @Environment(\.tooltipDirection) private var tooltipDirection
    @State var displayTooltip = false
    var action: ((_: ToolbarOptionType)) -> Void
    let type: ToolbarOptionType
    let placement: ListToolBarPlacement
    let useSpacing: Bool
    let size: CGFloat?
    private var leadingSpacing: CGFloat {
        if #available(iOS 26.0, *) {
            return 0
        } else {
            return -.padding12
        }
    }
    private var trailingSpacing: CGFloat {
        if #available(iOS 26.0, *) {
            return 0
        } else {
            return -.padding4
        }
    }

    private var badgeAlignment: Alignment {
        if #available(iOS 26.0, *) {
            return .center
        } else {
            return .topTrailing
        }
    }

    private var badgeOffset: CGSize {
        if #available(iOS 26.0, *) {
            return .init(width: 10, height: -8)
        } else {
            return .init(width: -.padding4, height: .padding4)
        }
    }

    public init(
        type: ToolbarOptionType,
        placement: ListToolBarPlacement,
        action: @escaping (_: ToolbarOptionType) -> Void,
        useSpacing: Bool = false,
        size: CGFloat? = nil
    ) {
        self.type = type
        self.placement = placement
        self.action = action
        self.useSpacing = useSpacing
        self.size = size
    }

    public var body: some View {
        VStack(alignment: .trailing) {
            SwiftUI.Button(action: {
                withAnimation(.spring()) {
                    displayTooltip = false
                }
                action(type)
            }) {
                ZStack(alignment: badgeAlignment) {
                    if type.shouldAnimate {
                        imageFor(type: type)
                            .rotate()
                    } else {
                        imageFor(type: type)
                    }
                    if type.showBadge {
                        Circle()
                            .fill(hSignalColor.Red.element)
                            .frame(width: 10, height: 10)
                            .background {
                                Circle()
                                    .fill(hBackgroundColor.primary)
                                    .frame(width: 12, height: 12)
                            }
                            .offset(badgeOffset)
                    }
                }
                .frame(width: size, height: size)
            }
            // The inner image is accessibility-hidden, so the button synthesizes no label
            // of its own — without this, VoiceOver announces a bare "Button".
            .accessibilityLabel(type.accessibilityDisplayName)
            .padding(.leading, useSpacing ? leadingSpacing : 0)
            .padding(.trailing, useSpacing ? trailingSpacing : 0)
        }
        .showTooltip(type: type, placement: placement, direction: tooltipDirection)
    }

    private func imageFor(type: ToolbarOptionType) -> some View {
        type.image
            .resizable()
            .scaledToFill()
            .accessibilityHidden(true)
            .frame(width: type.imageSize, height: type.imageSize)
            .foregroundColor(type.imageTintColor)
            .shadow(color: type.shadowColor, radius: 1, x: 0, y: 1)
            .accessibilityValue(type.accessibilityDisplayName)
    }
}

public struct ToolbarViewModifier<Leading: View, Trailing: View>: ViewModifier {
    let action: (_: ToolbarOptionType) -> Void
    @Binding var types: [ToolbarOptionType]
    let placement: ListToolBarPlacement
    let collapsesIntoMenu: Bool

    let leading: Leading?
    let trailing: Trailing?
    let showLeading: Bool
    let showTrailing: Bool

    public init(
        leading: Leading?,
        trailing: Trailing?,
        showLeading: Bool,
        showTrailing: Bool
    ) {
        self.leading = leading
        self.trailing = trailing
        self.showLeading = showLeading
        self.showTrailing = showTrailing
        placement = leading == nil ? .trailing : .leading
        collapsesIntoMenu = false
        action = { _ in }
        _types = .constant([])
    }

    public init(
        action: @escaping (_: ToolbarOptionType) -> Void,
        types: Binding<[ToolbarOptionType]>,
        placement: ListToolBarPlacement,
        collapsesIntoMenu: Bool = false
    ) {
        self.action = action
        _types = types
        self.placement = placement
        self.collapsesIntoMenu = collapsesIntoMenu
        leading = nil
        trailing = nil
        showLeading = false
        showTrailing = false
    }

    public func body(content: Content) -> some View {
        // Resolved out here, where the screen's own safe area is still measurable, so the
        // toolbar items below inherit the direction instead of each caller supplying one.
        toolbar(for: content)
            .resolveTooltipDirection()
    }

    @ViewBuilder
    private func toolbar(for content: Content) -> some View {
        if let leading, showLeading {
            content
                .toolbar {
                    ToolbarItem(
                        placement: .topBarLeading
                    ) {
                        leading
                    }
                    .keptInBarWhenPossible()
                }
        } else if let trailing {
            content
                .toolbar {
                    ToolbarItem(
                        placement: .topBarTrailing
                    ) {
                        trailing
                    }
                    .keptInBarWhenPossible()
                }
        } else if collapsesIntoMenu {
            content
                .toolbar {
                    if !types.isEmpty {
                        ToolbarItem(placement: .topBarTrailing) {
                            ToolbarOptionsMenu(types: types, action: action)
                        }
                    }
                }
        } else {
            content
                .toolbar {
                    ToolbarTrailingItems(
                        types: types,
                        placement: placement,
                        action: action
                    )
                }
        }
    }
}

/// All the toolbar options behind a single button, for a toolbar with room for only one item.
/// Built by hand rather than left to the system's overflow menu, which cannot show the custom
/// views the options are drawn with and would list them as empty, inert entries.
private struct ToolbarOptionsMenu: View {
    let types: [ToolbarOptionType]
    let action: (_: ToolbarOptionType) -> Void

    var body: some View {
        Menu {
            ForEach(types, id: \.self) { type in
                SwiftUI.Button {
                    action(type)
                } label: {
                    // Plain `Text`, as a menu row only carries over system views.
                    Label {
                        Text(type.accessibilityDisplayName)
                    } icon: {
                        type.image
                    }
                }
            }
        } label: {
            // The system symbol already reads as "More" to VoiceOver.
            Image(systemName: "ellipsis")
                .overlay(alignment: .topTrailing) {
                    if types.contains(where: \.showBadge) {
                        Circle()
                            .fill(hSignalColor.Red.element)
                            .frame(width: 8, height: 8)
                            .offset(x: .padding6, y: -.padding6)
                            .accessibilityHidden(true)
                    }
                }
        }
    }
}

private struct ToolbarTrailingItems: ToolbarContent {
    let types: [ToolbarOptionType]
    let placement: ListToolBarPlacement
    let action: (_: ToolbarOptionType) -> Void

    private func button(_ type: ToolbarOptionType) -> some View {
        ToolbarButtonView(
            type: type,
            placement: placement,
            action: action,
            useSpacing: true
        )
    }

    var body: some ToolbarContent {
        if types.indices.contains(0) {
            ToolbarItem(id: types[0].toolbarItemId, placement: .topBarTrailing) {
                button(types[0])
            }
            .keptInBarWhenPossible()
        }
        if #available(iOS 26.0, *), types.indices.contains(1) {
            ToolbarSpacer(.fixed, placement: .topBarTrailing)
        }
        if types.indices.contains(1) {
            ToolbarItem(id: types[1].toolbarItemId, placement: .topBarTrailing) {
                button(types[1])
            }
            .keptInBarWhenPossible()
        }
        if #available(iOS 26.0, *), types.indices.contains(2) {
            ToolbarSpacer(.fixed, placement: .topBarTrailing)
        }
        if types.indices.contains(2) {
            ToolbarItem(id: types[2].toolbarItemId, placement: .topBarTrailing) {
                button(types[2])
            }
            .keptInBarWhenPossible()
        }
        if #available(iOS 26.0, *), types.indices.contains(3) {
            ToolbarSpacer(.fixed, placement: .topBarTrailing)
        }
        if types.indices.contains(3) {
            ToolbarItem(id: types[3].toolbarItemId, placement: .topBarTrailing) {
                button(types[3])
            }
            .keptInBarWhenPossible()
        }
        if #available(iOS 26.0, *), types.indices.contains(4) {
            ToolbarSpacer(.fixed, placement: .topBarTrailing)
        }
        if types.indices.contains(4) {
            ToolbarItem(id: types[4].toolbarItemId, placement: .topBarTrailing) {
                button(types[4])
            }
            .keptInBarWhenPossible()
        }
    }
}

extension ToolbarContent {
    /// Keeps the item in the bar for as long as it fits, ahead of anything else that could
    /// overflow. These buttons are custom views, which the overflow menu cannot show, so once
    /// moved there they would be an empty entry — as in the short side column of a folded
    /// iPhone Duo.
    @ToolbarContentBuilder
    fileprivate func keptInBarWhenPossible() -> some ToolbarContent {
        if #available(iOS 27.0, *) {
            visibilityPriority(.high)
        } else {
            self
        }
    }
}

extension TimeInterval {
    public static func days(numberOfDays: Int) -> TimeInterval {
        Double(numberOfDays) * 24 * 60 * 60
    }
}

extension View {
    public func setHomeNavigationBars(
        with options: Binding<[ToolbarOptionType]>,
        action: @escaping (_: ToolbarOptionType) -> Void,
        collapsesIntoMenu: Bool = false
    ) -> some View {
        ModifiedContent(
            content: self,
            modifier: ToolbarViewModifier<EmptyView, EmptyView>(
                action: action,
                types: options,
                placement: .trailing,
                collapsesIntoMenu: collapsesIntoMenu
            )
        )
    }

    public func setToolbar<Leading: View, Trailing: View>(
        @ViewBuilder _ leading: () -> Leading,
        @ViewBuilder _ trailing: () -> Trailing
    ) -> some View {
        modifier(
            ToolbarViewModifier(
                leading: leading(),
                trailing: trailing(),
                showLeading: true,
                showTrailing: true
            )
        )
    }

    public func setToolbarLeading<Leading: View>(
        @ViewBuilder content leading: () -> Leading
    ) -> some View {
        modifier(
            ToolbarViewModifier(
                leading: leading(),
                trailing: EmptyView(),
                showLeading: true,
                showTrailing: false
            )
        )
    }

    public func setToolbarTrailing<Trailing: View>(
        @ViewBuilder _ trailing: () -> Trailing
    ) -> some View {
        modifier(
            ToolbarViewModifier(
                leading: EmptyView(),
                trailing: trailing(),
                showLeading: false,
                showTrailing: true
            )
        )
    }
}

public enum ListToolBarPlacement {
    case trailing
    case leading
}
