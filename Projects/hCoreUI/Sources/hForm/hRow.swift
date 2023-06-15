import Foundation
import SwiftUI

enum hRowPosition {
    case top
    case middle
    case bottom
    case unique
}

private struct EnvironmentHRowPosition: EnvironmentKey {
    static let defaultValue = hRowPosition.unique
}

extension EnvironmentValues {
    var hRowPosition: hRowPosition {
        get { self[EnvironmentHRowPosition.self] }
        set { self[EnvironmentHRowPosition.self] = newValue }
    }
}

struct RowButtonStyle: SwiftUI.ButtonStyle {
    @Environment(\.hUseNewStyle) var hUseNewStyle

    func makeBody(configuration: Configuration) -> some View {
        configuration
            .label
            .background(
                configuration.isPressed
                    ? (hUseNewStyle
                        ? Color(UIColor.brandNew(.primaryBackground(true))).opacity(0.1)
                        : Color(UIColor.brand(.primaryBackground(true))).opacity(0.1))
                    : Color.clear
            )
            .animation(
                .easeOut(duration: 0.2).delay(configuration.isPressed ? 0 : 0.15),
                value: configuration.isPressed
            )
    }
}

public struct hRow<Content: View, Accessory: View>: View {
    @SwiftUI.Environment(\.hRowPosition) var position: hRowPosition

    var content: Content
    var accessory: Accessory
    var horizontalPadding: CGFloat = 21
    var verticalPadding: CGFloat = 21

    public init(
        _ accessory: Accessory,
        @ViewBuilder _ builder: () -> Content
    ) {
        self.content = builder()
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

    public var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            VStack(alignment: .leading) {
                HStack {
                    content
                    accessory
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding([.horizontal], horizontalPadding)
            .padding([.vertical], verticalPadding)
            if position == .middle || position == .top {
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
        self.content = builder()
        self.accessory = EmptyView()
    }
}

public struct StandaloneChevronAccessory: View {
    public init() {}

    public var body: some View {
        Image(uiImage: hCoreUIAssets.chevronRight.image)
    }
}

public struct StandaloneChevronNewAccessory: View {
    public init() {}

    public var body: some View {
        Image(uiImage: hCoreUIAssets.chevronRight2.image)
            .foregroundColor(hLabelColorNew.tertiary)
    }
}

public struct ChevronAccessory: View {
    public init() {}

    public var body: some View {
        Spacer()
        StandaloneChevronAccessory()
    }
}

public struct ChevronNewAccessory: View {
    public init() {}

    public var body: some View {
        Spacer()
        StandaloneChevronNewAccessory()
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
            Image(uiImage: hCoreUIAssets.checkmark.image)
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

    public var withNewChevronAccessory: hRow<Content, ChevronNewAccessory> {
        hRow<Content, ChevronNewAccessory>(ChevronNewAccessory()) {
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

extension hRow {
    func wrapInButton(_ onTap: @escaping () -> Void) -> some View {
        SwiftUI.Button(
            action: onTap,
            label: {
                self
            }
        )
        .buttonStyle(RowButtonStyle())
    }

    public func onTap(_ onTap: @escaping () -> Void) -> some View where Accessory == EmptyView {
        self.withChevronAccessory.wrapInButton(onTap)
    }

    public func onTap(_ onTap: @escaping () -> Void) -> some View {
        self.wrapInButton(onTap)
    }

    /// Attaches onTap handler only if passed boolean is true
    @ViewBuilder public func onTap(if: Bool, _ onTap: @escaping () -> Void) -> some View {
        if `if` {
            self.wrapInButton(onTap)
        } else {
            self
        }
    }
}
