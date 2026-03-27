import Foundation
import SwiftUI

@resultBuilder
public struct RowViewBuilder {
    public static func buildPartialBlock<V: View>(first: V) -> V {
        first
    }

    @ViewBuilder
    public static func buildPartialBlock<Accumulated: View, Next: View>(
        accumulated: Accumulated,
        next: Next?
    ) -> some View {
        accumulated.transformEnvironment(\.hasContentBelow) { $0 = $0 || next.hasConcreteValue }
        next
    }

    public static func buildOptional<V: View>(_ view: V?) -> V? {
        view
    }

    public static func buildEither<TrueContent: View, FalseContent: View>(
        first: TrueContent
    ) -> _ConditionalContent<TrueContent, FalseContent> {
        ViewBuilder.buildEither(first: first)
    }

    public static func buildEither<TrueContent: View, FalseContent: View>(
        second: FalseContent
    ) -> _ConditionalContent<TrueContent, FalseContent> {
        ViewBuilder.buildEither(second: second)
    }
}

private protocol _OptionalProtocol {
    var deeplyUnwrapped: Any? { get }
}
extension _OptionalProtocol {
    fileprivate var hasConcreteValue: Bool { deeplyUnwrapped != nil }
}

private protocol _MaybeEmpty {
    var isEmpty: Bool { get }
}

extension Optional: _OptionalProtocol {
    var deeplyUnwrapped: Any? {
        switch self {
        case .none: nil
        case .some(let wrapped as _OptionalProtocol): wrapped.deeplyUnwrapped
        case .some(let wrapped as _MaybeEmpty) where wrapped.isEmpty: nil
        case .some(let wrapped): wrapped
        }
    }
}

extension hForEach: @MainActor _MaybeEmpty {
    var isEmpty: Bool { data.isEmpty }
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
        modifier(hShadowModifier(type: type, show: show))
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
    case negative
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

extension View {
    /// set section container style
    public func sectionContainerStyle(_ style: hSectionContainerStyle) -> some View {
        environment(\.hSectionContainerStyle, style)
    }
}

@MainActor
private struct EnvironmentHSectionContainerMaskerCorners: @preconcurrency EnvironmentKey {
    static let defaultValue = UIRectCorner.allCorners
}

extension EnvironmentValues {
    var hSectionContainerCornerMaskedCorners: UIRectCorner {
        get { self[EnvironmentHSectionContainerMaskerCorners.self] }
        set { self[EnvironmentHSectionContainerMaskerCorners.self] = newValue }
    }
}

extension View {
    /// set section container style
    public func sectionContainerCornerMaskerCorners(_ corners: UIRectCorner) -> some View {
        environment(\.hSectionContainerCornerMaskedCorners, corners)
    }
}

struct hSectionContainerStyleModifier: ViewModifier {
    @Environment(\.hSectionContainerStyle) var containerStyle
    @Environment(\.hSectionContainerCornerMaskedCorners) var maskedCorners
    func body(content: Content) -> some View {
        switch containerStyle {
        case .transparent:
            content
        case .opaque:
            content.background(
                hSurfaceColor.Opaque.primary
            )
            .clipShape(hRoundedRectangle(cornerRadius: .cornerRadiusL, corners: maskedCorners))
        case .black:
            content.background(
                hColorScheme(
                    light: hFillColor.Opaque.black,
                    dark: hSurfaceColor.Opaque.primary
                )
            )
            .clipShape(RoundedRectangle(cornerRadius: .cornerRadiusL))
        case .negative:
            content.background(
                hFillColor.Opaque.negative
            )
            .clipShape(hRoundedRectangle(cornerRadius: .cornerRadiusXL, corners: maskedCorners))
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
        environment(\.hWithoutDivider, true)
    }

    public func shouldShowDivider(_ show: Bool) -> some View {
        environment(\.hWithoutDivider, show)
    }
}

public struct HorizontalPadding: OptionSet, Sendable {
    public init(rawValue: UInt) {
        self.rawValue = rawValue
    }

    public let rawValue: UInt
    public static let none = HorizontalPadding(rawValue: 0 << 0)
    public static let section = HorizontalPadding(rawValue: 1 << 0)
    public static let row = HorizontalPadding(rawValue: 1 << 1)
    public static let divider = HorizontalPadding(rawValue: 1 << 2)
    public static let all: HorizontalPadding = [.section, .row, .divider]
}

private struct EnvironmentHWithoutHorizontalPadding: EnvironmentKey {
    static let defaultValue: HorizontalPadding = .none
}

extension EnvironmentValues {
    public var hWithoutHorizontalPadding: HorizontalPadding {
        get { self[EnvironmentHWithoutHorizontalPadding.self] }
        set { self[EnvironmentHWithoutHorizontalPadding.self] = newValue }
    }
}

extension View {
    public func hWithoutHorizontalPadding(_ attributes: HorizontalPadding) -> some View {
        environment(\.hWithoutHorizontalPadding, attributes)
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
        environment(\.hSectionHeaderWithDivider, true)
    }
}

struct hSectionContainer<Content: View>: View {
    var content: Content

    init(
        @ViewBuilder _ builder: @escaping () -> Content
    ) {
        content = builder()
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
        content = builder()
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
                VStack(alignment: .leading, spacing: .padding8) {
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
            withInfoButton = infoButtonDescription != nil
        }

        public var body: some View {
            VStack(alignment: .leading, spacing: .padding16) {
                headerView
                bottomExtraView
            }
            .padding(.bottom, withoutBottomPadding ? -8 : .padding8)
        }

        private var headerView: some View {
            HStack {
                topExtraView

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
        }

        @ViewBuilder
        private var topExtraView: some View {
            if let extraView, extraView.alignment == .top {
                extraView.view
            }
        }

        @ViewBuilder
        private var bottomExtraView: some View {
            if let extraView, extraView.alignment == .bottom {
                extraView.view
            }
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

public struct hForEach<Element: Identifiable, RowContent: View>: View {
    @Environment(\.hasContentBelow) var parentHasContentBelow
    let data: [Element]
    let content: (Element) -> RowContent

    public init(_ data: [Element], @ViewBuilder content: @escaping (Element) -> RowContent) {
        self.data = data
        self.content = content
    }

    public var body: some View {
        if !data.isEmpty {
            ForEach(Array(data.enumerated()), id: \.element.id) { index, element in
                let isLast = index == data.count - 1
                content(element)
                    .environment(\.hasContentBelow, !isLast || parentHasContentBelow)
            }
        }
    }
}

extension hSection where Content == AnyView, Header == EmptyView {
    internal struct IdentifiableContent: Identifiable {
        var id: AnyHashable
        var hasContentBelow: Bool
        var content: Content
    }

    public init<Element, BuilderContent: View>(
        _ list: [Element],
        @ViewBuilder _ builder: @escaping (_ element: Element) -> BuilderContent
    ) where Element: Identifiable {
        let list: [IdentifiableContent] = list.enumerated()
            .map { index, element in
                .init(
                    id: element.id,
                    hasContentBelow: index < list.count - 1,
                    content: AnyView(builder(element))
                )
            }

        content = AnyView(
            ForEach(list) { element in
                VStack(spacing: 0) {
                    element.content
                }
                .environment(\.hasContentBelow, element.hasContentBelow)
            }
        )
    }

    public init<Element, Hash: Hashable, BuilderContent: View>(
        _ list: [Element],
        id: KeyPath<Element, Hash>,
        @RowViewBuilder _ builder: @escaping (_ element: Element) -> BuilderContent
    ) {
        let list: [IdentifiableContent] = list.enumerated()
            .map { index, element in
                .init(
                    id: element[keyPath: id],
                    hasContentBelow: index < list.count - 1,
                    content: AnyView(builder(element))
                )
            }

        content = AnyView(
            ForEach(list) { element in
                VStack(spacing: 0) {
                    element.content
                }
                .environment(\.hasContentBelow, element.hasContentBelow)
            }
        )
    }
}

// MARK: - Previews

private struct PreviewItem: Identifiable {
    let id: String
    let title: String
}

#Preview("Static rows") {
    VStack(spacing: 32) {
        hSection {
            hRow { hText("Single row — no divider") }
        }
        hSection {
            hRow { hText("Row 1") }
            hRow { hText("Row 2") }
            hRow { hText("Row 3 — no trailing divider") }
        }
    }
}

#Preview("Conditional rows") {
    VStack(spacing: 32) {
        hSection {
            hRow { hText("Trailing if false — no divider") }
            if false { hRow { hText("Hidden") } }
        }
        hSection {
            hRow { hText("Row 1 — divider despite hidden middle") }
            if false { hRow { hText("Hidden") } }
            hRow { hText("Row 2") }
        }
        hSection {
            hRow { hText("Nested if false — no divider") }
            if true {
                if false { hRow { hText("Hidden") } }
            }
        }
    }
}

#Preview("hForEach") {
    let items = (1...3).map { PreviewItem(id: "\($0)", title: "Item \($0)") }

    VStack(spacing: 32) {
        hSection {
            hRow { hText("Before empty hForEach — no divider") }
            hForEach([PreviewItem]()) { item in
                hRow { hText(item.title) }
            }
        }
        hSection {
            hForEach(items) { item in
                hRow { hText(item.title) }
            }
            hRow { hText("Trailing row — divider above") }
        }
    }
}

#Preview("hWithoutDivider") {
    hSection {
        hRow { hText("Row 1") }
        hRow { hText("Row 2") }
        hRow { hText("Row 3 — no dividers anywhere") }
    }
    .hWithoutDivider
}

#Preview("Header & container styles") {
    ScrollView {
        VStack(spacing: 32) {
            hSection {
                hRow { hText("Row") }
                hRow { hText("Row") }
            }
            .withHeader(title: "Section Header")

            hSection {
                hRow { hText("Transparent") }
                hRow { hText("Transparent") }
            }
            .sectionContainerStyle(.transparent)

            hSection {
                hRow { hText("Black") }
                hRow { hText("Black") }
            }
            .foregroundColor(hTextColor.Opaque.white)
            .sectionContainerStyle(.black)

            hSection {
                hRow { hText("Negative") }
                hRow { hText("Negative") }
            }
            .sectionContainerStyle(.negative)
        }
    }
}
