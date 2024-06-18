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
    case caution
    case alert
    case black
}

private struct EnvironmentHSectionContainerStyle: EnvironmentKey {
    static let defaultValue = hSectionContainerStyle.opaque
}

extension EnvironmentValues {
    var hSectionContainerStyle: hSectionContainerStyle {
        get { self[EnvironmentHSectionContainerStyle.self] }
        set { self[EnvironmentHSectionContainerStyle.self] = newValue }
    }
}

struct hSectionContainerStyleModifier: ViewModifier {
    @Environment(\.hUseNewDesign) var useNewDesign
    @Environment(\.hSectionContainerStyle) var containerStyle

    public func body(content: Content) -> some View {
        switch containerStyle {
        case .transparent:
            content
        case .opaque:
            content.background(
                hSurfaceColor.Opaque.primary
            )
            .clipShape(Squircle.default())
        case .caution:
            content.background(
                hSignalColor.Amber.element
            )
            .border(
                Color(UIColor.brand(.primaryBorderColor))
            )
        case .alert:
            content.background(
                hSignalColor.Amber.fill
            )
            .clipShape(Squircle.default())
        case .black:
            content.background(
                hColorScheme(
                    light: hFillColor.Opaque.black,
                    dark: hSurfaceColor.Opaque.primary
                )
            )
            .clipShape(Squircle.default())
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
}

private struct EnvironmentHSectionMinimumPadding: EnvironmentKey {
    static let defaultValue = false
}

extension EnvironmentValues {
    public var minimumPadding: Bool {
        get { self[EnvironmentHSectionMinimumPadding.self] }
        set { self[EnvironmentHSectionMinimumPadding.self] = newValue }
    }
}

extension View {
    public var hSectionMinimumPadding: some View {
        self.environment(\.minimumPadding, true)
    }
}

private struct EnvironmentHWithoutHorizontalPadding: EnvironmentKey {
    static let defaultValue = false
}

extension EnvironmentValues {
    public var hWithoutHorizontalPadding: Bool {
        get { self[EnvironmentHWithoutHorizontalPadding.self] }
        set { self[EnvironmentHWithoutHorizontalPadding.self] = newValue }
    }
}

extension View {
    public var hWithoutHorizontalPadding: some View {
        self.environment(\.hWithoutHorizontalPadding, true)
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

public struct hSection<Header: View, Content: View, Footer: View>: View {
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    @Environment(\.minimumPadding) var minimumPadding

    var header: Header?
    var content: Content
    var footer: Footer?

    public init(
        header: Header? = nil,
        footer: Footer? = nil,
        @RowViewBuilder _ builder: @escaping () -> Content
    ) {
        self.header = header
        self.footer = footer
        self.content = builder()
    }

    init(
        header: Header? = nil,
        content: Content,
        footer: Footer? = nil
    ) {
        self.header = header
        self.footer = footer
        self.content = content
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            if header != nil {
                VStack(alignment: .leading) {
                    header
                        .environment(\.defaultHTextStyle, .body1)
                }
                .foregroundColor(hTextColor.Opaque.primary)
                .padding(.bottom, .padding16)
            }
            hSectionContainer {
                content
            }
            if footer != nil {
                VStack(alignment: .leading) {
                    footer
                        .environment(\.defaultHTextStyle, .footnote)
                }
                .foregroundColor(hTextColor.Opaque.secondary)
                .padding(.horizontal, 15)
                .padding(.top, .padding10)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.horizontal, minimumPadding ? 16 : (horizontalSizeClass == .regular ? 60 : 16))
    }

    /// removes hSection leading and trailing padding
    public var withoutHorizontalPadding: some View {
        self
            .padding(.horizontal, horizontalSizeClass == .regular ? -60 : -16)
    }

    public func withHeader<Header: View>(
        @ViewBuilder _ builder: @escaping () -> Header
    ) -> hSection<Header, Content, Footer> {
        return hSection<Header, Content, Footer>(header: builder(), content: content, footer: footer)
    }

    public func withFooter<Footer: View>(
        @ViewBuilder _ builder: @escaping () -> Footer
    ) -> hSection<Header, Content, Footer> {
        return hSection<Header, Content, Footer>(header: header, content: content, footer: builder())
    }
}

extension hSection where Header == EmptyView {
    public init(
        footer: Footer? = nil,
        @RowViewBuilder _ builder: @escaping () -> Content
    ) {
        self.init(header: nil, footer: footer, builder)
    }
}

extension hSection where Footer == EmptyView {
    public init(
        header: Header? = nil,
        @RowViewBuilder _ builder: @escaping () -> Content
    ) {
        self.init(header: header, footer: nil, builder)
    }
}

extension hSection where Header == EmptyView, Footer == EmptyView {
    public init(
        @RowViewBuilder _ builder: @escaping () -> Content
    ) {
        self.init(header: nil, footer: nil, builder)
    }
}

extension hSection where Content == AnyView, Header == EmptyView, Footer == EmptyView {
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
