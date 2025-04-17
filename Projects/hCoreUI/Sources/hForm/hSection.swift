import Foundation
import SwiftUI

@resultBuilder
public struct RowViewBuilder {
    public static func buildBlock<V: View>(_ view: V) -> some View {
        return view
    }

    public static func buildOptional<V: View>(_ view: V?) -> some View {
        TupleView(view)
    }

    public static func buildBlock<A: View, B: View>(
        _ viewA: A,
        _ viewB: B
    ) -> some View {
        return TupleView((viewA.environment(\.hRowPosition, .top), viewB.environment(\.hRowPosition, .bottom)))
    }

    public static func buildBlock<A: View, B: View, C: View>(
        _ viewA: A,
        _ viewB: B,
        _ viewC: C
    ) -> some View {
        return TupleView(
            (
                viewA.environment(\.hRowPosition, .top), viewB.environment(\.hRowPosition, .middle),
                viewC.environment(\.hRowPosition, .bottom)
            )
        )
    }

    public static func buildBlock<A: View, B: View, C: View, D: View>(
        _ viewA: A,
        _ viewB: B,
        _ viewC: C,
        _ viewD: D
    ) -> some View {
        return TupleView(
            (
                viewA.environment(\.hRowPosition, .top), viewB.environment(\.hRowPosition, .middle),
                viewC.environment(\.hRowPosition, .middle), viewD.environment(\.hRowPosition, .bottom)
            )
        )
    }
    public static func buildBlock<A: View, B: View, C: View, D: View, E: View>(
        _ viewA: A,
        _ viewB: B,
        _ viewC: C,
        _ viewD: D,
        _ viewE: E
    ) -> some View {
        return TupleView(
            (
                viewA.environment(\.hRowPosition, .top), viewB.environment(\.hRowPosition, .middle),
                viewC.environment(\.hRowPosition, .middle), viewD.environment(\.hRowPosition, .middle),
                viewE.environment(\.hRowPosition, .bottom)
            )
        )
    }

    public static func buildBlock<A: View, B: View, C: View, D: View, E: View, F: View>(
        _ viewA: A,
        _ viewB: B,
        _ viewC: C,
        _ viewD: D,
        _ viewE: E,
        _ viewF: F
    ) -> some View {
        return TupleView(
            (
                viewA.environment(\.hRowPosition, .top), viewB.environment(\.hRowPosition, .middle),
                viewC.environment(\.hRowPosition, .middle), viewD.environment(\.hRowPosition, .middle),
                viewE.environment(\.hRowPosition, .middle), viewF.environment(\.hRowPosition, .bottom)
            )
        )
    }

    public static func buildBlock<A: View, B: View, C: View, D: View, E: View, F: View, G: View>(
        _ viewA: A,
        _ viewB: B,
        _ viewC: C,
        _ viewD: D,
        _ viewE: E,
        _ viewF: F,
        _ viewG: G
    ) -> some View {
        return TupleView(
            (
                viewA.environment(\.hRowPosition, .top), viewB.environment(\.hRowPosition, .middle),
                viewC.environment(\.hRowPosition, .middle), viewD.environment(\.hRowPosition, .middle),
                viewE.environment(\.hRowPosition, .middle), viewF.environment(\.hRowPosition, .middle),
                viewG.environment(\.hRowPosition, .bottom)
            )
        )
    }

    public static func buildBlock<A: View, B: View, C: View, D: View, E: View, F: View, G: View, H: View, I: View>(
        _ viewA: A,
        _ viewB: B,
        _ viewC: C,
        _ viewD: D,
        _ viewE: E,
        _ viewF: F,
        _ viewG: G,
        _ viewH: H
    ) -> some View {
        return TupleView(
            (
                viewA.environment(\.hRowPosition, .top), viewB.environment(\.hRowPosition, .middle),
                viewC.environment(\.hRowPosition, .middle), viewD.environment(\.hRowPosition, .middle),
                viewE.environment(\.hRowPosition, .middle), viewF.environment(\.hRowPosition, .middle),
                viewG.environment(\.hRowPosition, .middle), viewH.environment(\.hRowPosition, .bottom)
            )
        )
    }

    public static func buildBlock<A: View, B: View, C: View, D: View, E: View, F: View, G: View, H: View, I: View>(
        _ viewA: A,
        _ viewB: B,
        _ viewC: C,
        _ viewD: D,
        _ viewE: E,
        _ viewF: F,
        _ viewG: G,
        _ viewH: H,
        _ viewI: I
    ) -> some View {
        return TupleView(
            (
                viewA.environment(\.hRowPosition, .top), viewB.environment(\.hRowPosition, .middle),
                viewC.environment(\.hRowPosition, .middle), viewD.environment(\.hRowPosition, .middle),
                viewE.environment(\.hRowPosition, .middle), viewF.environment(\.hRowPosition, .middle),
                viewG.environment(\.hRowPosition, .middle), viewH.environment(\.hRowPosition, .middle),
                viewI.environment(\.hRowPosition, .bottom)
            )
        )
    }
}

private struct hShadowModifier: ViewModifier {
    let color: Color = .black
    let type: ShadowType
    let show: Bool
    func body(content: Content) -> some View {
        content.shadow(
            color: color.opacity(show ? type.opacity : 0),
            radius: type.radius,
            x: type.xOffset,
            y: type.yOffset
        )
    }
}

extension View {
    /// adds a Hedvig shadow to the view
    public func hShadow(type: ShadowType = .default, show: Bool = true) -> some View {
        self.modifier(hShadowModifier(type: type, show: show))
    }
}

public enum ShadowType {
    case `default`
    case light
    case custom(opacity: CGFloat, radius: CGFloat, xOffset: CGFloat, yOffset: CGFloat)

    var opacity: CGFloat {
        switch self {
        case .default:
            return 0.10
        case .light:
            return 0.05
        case let .custom(opacity, _, _, _):
            return opacity
        }
    }
    var radius: CGFloat {
        switch self {
        case .default:
            return 1
        case .light:
            return 5
        case let .custom(_, radius, _, _):
            return radius
        }
    }
    var xOffset: CGFloat {
        switch self {
        case .default:
            return 0
        case .light:
            return 0
        case let .custom(_, _, xOffset, _):
            return xOffset
        }
    }
    var yOffset: CGFloat {
        switch self {
        case .default:
            return 1
        case .light:
            return 2
        case let .custom(_, _, _, yOffset):
            return yOffset
        }
    }
}

public enum hSectionContainerStyle {
    case transparent
    case opaque
    case black
}

@MainActor
private struct EnvironmentHSectionContainerStyle: @preconcurrency EnvironmentKey {
    static let defaultValue = hSectionContainerStyle.opaque
}

extension EnvironmentValues {
    var hSectionContainerStyle: hSectionContainerStyle {
        get { self[EnvironmentHSectionContainerStyle.self] }
        set { self[EnvironmentHSectionContainerStyle.self] = newValue }
    }
}

struct hSectionContainerStyleModifier: ViewModifier {
    @Environment(\.hSectionContainerStyle) var containerStyle

    public func body(content: Content) -> some View {
        switch containerStyle {
        case .transparent:
            content
        case .opaque:
            content.background(
                hSurfaceColor.Opaque.primary
            )
            .clipShape(RoundedRectangle(cornerRadius: .cornerRadiusL))
        case .black:
            content.background(
                hColorScheme(
                    light: hFillColor.Opaque.black,
                    dark: hSurfaceColor.Opaque.primary
                )
            )
            .clipShape(RoundedRectangle(cornerRadius: .cornerRadiusL))
        }
    }
}

private struct EnvironmentHWithoutDivider: EnvironmentKey {
    static let defaultValue = false
}

extension EnvironmentValues {
    public var hWithoutDivider: Bool {
        get { self[EnvironmentHWithoutDivider.self] }
        set { self[EnvironmentHWithoutDivider.self] = newValue }
    }
}

extension View {
    public var hWithoutDivider: some View {
        self.environment(\.hWithoutDivider, true)
    }

    public func shouldShowDivider(_ show: Bool) -> some View {
        self.environment(\.hWithoutDivider, show)
    }
}

public enum HorizontalPadding: Sendable {
    case section
    case row
    case divider
}

private struct EnvironmentHWithoutHorizontalPadding: EnvironmentKey {
    static let defaultValue: [HorizontalPadding] = []
}

extension EnvironmentValues {
    public var hWithoutHorizontalPadding: [HorizontalPadding] {
        get { self[EnvironmentHWithoutHorizontalPadding.self] }
        set { self[EnvironmentHWithoutHorizontalPadding.self] = newValue }
    }
}

extension View {
    public func hWithoutHorizontalPadding(_ attributes: [HorizontalPadding]) -> some View {
        self.environment(\.hWithoutHorizontalPadding, attributes)
    }
}

private struct EnvironmentHSectionHeaderWithDivider: EnvironmentKey {
    static let defaultValue: Bool = false
}

extension EnvironmentValues {
    public var hSectionHeaderWithDivider: Bool {
        get { self[EnvironmentHSectionHeaderWithDivider.self] }
        set { self[EnvironmentHSectionHeaderWithDivider.self] = newValue }
    }
}

extension View {
    public var hSectionHeaderWithDivider: some View {
        self.environment(\.hSectionHeaderWithDivider, true)
    }
}

extension View {
    /// set section container style
    public func sectionContainerStyle(_ style: hSectionContainerStyle) -> some View {
        self.environment(\.hSectionContainerStyle, style)
    }
}

struct hSectionContainer<Content: View>: View {
    @Environment(\.hSectionContainerStyle) var containerStyle
    var content: Content

    init(
        @ViewBuilder _ builder: @escaping () -> Content
    ) {
        self.content = builder()
    }

    var body: some View {
        HStack {
            VStack(spacing: 0) {
                content
            }
            .frame(maxWidth: .infinity)
            .modifier(hSectionContainerStyleModifier())
        }
        .frame(maxWidth: .infinity)
    }
}

public struct hSection<Header: View, Content: View>: View {
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    @Environment(\.hWithoutHorizontalPadding) var hWithoutHorizontalPadding
    @Environment(\.hSectionHeaderWithDivider) var useHeaderDivider
    @Environment(\.hFieldSize) var fieldSize
    var header: Header?
    var content: Content

    public init(
        header: Header? = nil,
        @RowViewBuilder _ builder: @escaping () -> Content
    ) {
        self.header = header
        self.content = builder()
    }

    init(
        header: Header? = nil,
        content: Content
    ) {
        self.header = header
        self.content = content
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            if header != nil {
                VStack(spacing: .padding8) {
                    header
                        .environment(\.defaultHTextStyle, .body1)
                        .accessibilityAddTraits(.isHeader)
                        .foregroundColor(hTextColor.Opaque.primary)
                    if useHeaderDivider {
                        hRowDivider()
                    }
                }
            }
            hSectionContainer {
                content
            }
        }
        .frame(maxWidth: .infinity)
        .padding(
            .horizontal,
            hWithoutHorizontalPadding.contains(.section)
                ? 0 : (horizontalSizeClass == .regular ? .padding60 : fieldSize.horizontalPadding)
        )
    }

    public func withHeader(
        title: String,
        infoButtonDescription: String? = nil,
        withoutBottomPadding: Bool = false,
        extraView: (view: AnyView, alignment: VerticalAlignment)? = nil
    ) -> hSection<HeaderView<AnyView>, Content> {
        hSection<HeaderView, Content>(
            header: HeaderView(
                title: title,
                infoButtonDescription: infoButtonDescription,
                withoutBottomPadding: withoutBottomPadding,
                extraView: extraView
            ),
            content: content
        )
    }

    public struct HeaderView<ExtraView: View>: View {
        public typealias HeaderExtraView = (view: ExtraView, alignment: VerticalAlignment)
        let title: String
        let infoButtonDescription: String?
        let withInfoButton: Bool
        let withoutBottomPadding: Bool
        let extraView: HeaderExtraView?

        init(
            title: String,
            infoButtonDescription: String?,
            withoutBottomPadding: Bool,
            extraView: HeaderExtraView? = nil
        ) {
            self.title = title
            self.infoButtonDescription = infoButtonDescription
            self.withoutBottomPadding = withoutBottomPadding
            self.extraView = extraView
            self.withInfoButton = infoButtonDescription != nil
        }

        public var body: some View {
            VStack(alignment: .leading, spacing: .padding16) {
                HStack {
                    if let extraView = extraView, extraView.alignment == .top {
                        extraView.view
                    }

                    hText(title)
                    if withInfoButton, let infoButtonDescription {
                        Spacer()
                        InfoViewHolder(
                            title: title,
                            description: infoButtonDescription
                        )
                        .accessibilityAddTraits(.isButton)
                        .accessibilityHint(title)
                    }
                }

                if let extraView = extraView, extraView.alignment == .bottom {
                    extraView.view
                }
            }
            .padding(.bottom, withoutBottomPadding ? -8 : .padding8)
        }
    }
}

extension hSection where Header == EmptyView {
    public init(
        @RowViewBuilder _ builder: @escaping () -> Content
    ) {
        self.init(header: nil, builder)
    }
}

extension hSection where Content == AnyView, Header == EmptyView {
    struct IdentifiableContent: Identifiable {
        var id: Int
        var position: hRowPosition
        var content: Content
    }

    public init<Element, BuilderContent: View>(
        _ list: [Element],
        @ViewBuilder _ builder: @escaping (_ element: Element) -> BuilderContent
    ) where Element: Identifiable {

        let count = list.count
        let unique = count == 1
        let lastOffset = count - 1

        let list: [IdentifiableContent] = list.enumerated()
            .map { offset, element in
                var position: hRowPosition {
                    if unique {
                        return .unique
                    }

                    switch offset {
                    case lastOffset:
                        return .bottom
                    case 0:
                        return .top
                    default:
                        return .middle
                    }
                }

                return IdentifiableContent(
                    id: element.id.hashValue,
                    position: position,
                    content: AnyView(builder(element))
                )
            }

        self.content = AnyView(
            ForEach(list) { element in
                VStack(spacing: 0) {
                    element.content
                }
                .environment(\.hRowPosition, element.position)
            }
        )

    }

    public init<Element, Hash: Hashable, BuilderContent: View>(
        _ list: [Element],
        id: KeyPath<Element, Hash>,
        @RowViewBuilder _ builder: @escaping (_ element: Element) -> BuilderContent
    ) {
        let count = list.count
        let unique = count == 1
        let lastOffset = count - 1

        let list: [IdentifiableContent] = list.enumerated()
            .map { offset, element in
                var position: hRowPosition {
                    if unique {
                        return .unique
                    }

                    switch offset {
                    case lastOffset:
                        return .bottom
                    case 0:
                        return .top
                    default:
                        return .middle
                    }
                }

                return IdentifiableContent(
                    id: element[keyPath: id].hashValue,
                    position: position,
                    content: AnyView(builder(element))
                )
            }

        self.content = AnyView(
            ForEach(list) { element in
                VStack(spacing: 0) {
                    element.content
                }
                .environment(\.hRowPosition, element.position)
            }
        )
    }
}
