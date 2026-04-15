import Foundation
import SwiftUI

extension EnvironmentValues {
    @Entry var hasContentBelow: Bool = false
}

struct RowButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration
            .label
            .background(
                configuration.isPressed
                    ? Color.clear

                    : Color.clear
            )
            .animation(
                .easeOut(duration: 0.2).delay(configuration.isPressed ? 0 : 0.15),
                value: configuration.isPressed
            )
    }
}

public struct hRow<Content: View, Accessory: View>: View {
    @Environment(\.hasContentBelow) var hasContentBelow
    @Environment(\.hWithoutDivider) var hWithoutDivider
    @Environment(\.hWithoutHorizontalPadding) var hWithoutHorizontalPadding
    @Environment(\.hRowContentAlignment) var contentAlignment
    var content: Content
    var accessory: Accessory
    var horizontalPadding: CGFloat = 16
    var verticalPadding: CGFloat = 16
    var topPadding: CGFloat = 0
    var bottomPadding: CGFloat = 0

    public init(
        _ accessory: Accessory,
        @ViewBuilder _ builder: () -> Content
    ) {
        content = builder()
        self.accessory = accessory
    }

    /// Removes spacing from hRow
    public func noSpacing() -> Self {
        var new = self
        new.verticalPadding = 0
        new.horizontalPadding = 0
        return new
    }

    public func verticalPadding(_ newPadding: CGFloat) -> Self {
        var new = self
        new.verticalPadding = newPadding
        return new
    }

    public func topPadding(_ newPadding: CGFloat) -> Self {
        var new = self
        new.topPadding = newPadding
        return new
    }

    public func bottomPadding(_ newPadding: CGFloat) -> Self {
        var new = self
        new.bottomPadding = newPadding
        return new
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            VStack(alignment: .leading) {
                HStack(alignment: contentAlignment) {
                    content
                    accessory
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, hWithoutHorizontalPadding.contains(.row) ? 0 : horizontalPadding)
            .padding(.vertical, verticalPadding)
            .padding(.top, topPadding)
            .padding(.bottom, bottomPadding)
            if hasContentBelow, !hWithoutDivider {
                hRowDivider()
            }
        }
        .contentShape(Rectangle())
    }
}

extension hRow where Accessory == EmptyView {
    public init(
        @ViewBuilder _ builder: () -> Content
    ) {
        content = builder()
        accessory = EmptyView()
    }
}

public struct StandaloneChevronAccessory: View {
    public init() {}

    public var body: some View {
        hCoreUIAssets.chevronRight.view
            .foregroundColor(hFillColor.Opaque.primary)
    }
}

public struct ChevronAccessory: View {
    public init() {}

    public var body: some View {
        StandaloneChevronAccessory()
    }
}

public struct EmptyAccessory: View {
    public var body: some View {
        EmptyView()
    }
}

public struct SelectedAccessory: View {
    var selected: Bool

    public var body: some View {
        Spacer()
        if selected {
            hCoreUIAssets.checkmark.view
        }
    }
}

extension hRow {
    /// Adds a chevron to trailing, indicating a tappable row
    public var withChevronAccessory: hRow<Content, ChevronAccessory> {
        hRow<Content, ChevronAccessory>(ChevronAccessory()) {
            content
        }
    }

    /// Adds an accessory indicating that row is currently selected
    public func withSelectedAccessory(_ selected: Bool) -> hRow<Content, SelectedAccessory> {
        hRow<Content, SelectedAccessory>(SelectedAccessory(selected: selected)) {
            content
        }
    }

    /// Adds a custom accessory
    public func withCustomAccessory<AccessoryContent: View>(
        @ViewBuilder _ builder: () -> AccessoryContent
    ) -> hRow<Content, AccessoryContent> {
        hRow<Content, AccessoryContent>(builder()) {
            content
        }
    }

    /// Adds an empty accessory
    public var withEmptyAccessory: hRow<Content, EmptyAccessory> {
        hRow<Content, EmptyAccessory>(EmptyAccessory()) {
            content
        }
    }
}

extension EnvironmentValues {
    @Entry var hRowContentAlignment: VerticalAlignment = .top
}

extension View {
    public func hRowContentAlignment(_ alignment: VerticalAlignment) -> some View {
        environment(\.hRowContentAlignment, alignment)
    }
}

extension hRow {
    internal func wrapInButton(_ onTap: @escaping () -> Void) -> some View {
        Button(
            action: {
                onTap()
                let generator = UIImpactFeedbackGenerator(style: .light)
                generator.impactOccurred()
            },
            label: {
                self
            }
        )
        .buttonStyle(RowButtonStyle())
    }

    public func onTap(_ onTap: @escaping () -> Void) -> some View where Accessory == EmptyView {
        withChevronAccessory.wrapInButton(onTap)
    }

    public func onTap(_ onTap: @escaping () -> Void) -> some View {
        wrapInButton(onTap)
    }

    /// Attaches onTap handler only if passed boolean is true
    @ViewBuilder public func onTap(if: Bool, _ onTap: @escaping () -> Void) -> some View {
        if `if` {
            wrapInButton(onTap)
        } else {
            self
        }
    }
}

private struct AsRowModifier: ViewModifier {
    let noSpacing: Bool
    func body(content: Content) -> some View {
        if noSpacing {
            hRow { content }.noSpacing()
        } else {
            hRow { content }
        }
    }
}

extension View {
    @ViewBuilder
    public func wrapInRow(noSpacing: Bool = true) -> some View {
        modifier(AsRowModifier(noSpacing: noSpacing))
    }
}
