import Foundation
import SwiftUI
import UIKit

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
                viewC.environment(\.hRowPosition, .middle), viewD.environment(\.hRowPosition, .middle)
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
                viewE.environment(\.hRowPosition, .middle)
            )
        )
    }
}

struct hShadowModifier: ViewModifier {
    func body(content: Content) -> some View {
        content.shadow(color: Color.black.opacity(0.1), radius: 2, x: 0, y: 1)
    }
}

extension View {
    /// adds a Hedvig shadow to the view
    public func hShadow() -> some View {
        self.modifier(hShadowModifier())
    }
}

public enum hSectionContainerStyle {
    case transparent
    case opaque(useNewDesign: Bool)
    case caution(useNewDesign: Bool)
}

private struct EnvironmentHSectionContainerStyle: EnvironmentKey {
    static let defaultValue = hSectionContainerStyle.opaque(useNewDesign: false)
}

extension EnvironmentValues {
    var hSectionContainerStyle: hSectionContainerStyle {
        get { self[EnvironmentHSectionContainerStyle.self] }
        set { self[EnvironmentHSectionContainerStyle.self] = newValue }
    }
}

extension hSectionContainerStyle: ViewModifier {
    public func body(content: Content) -> some View {
        switch self {
        case .transparent:
            content
        case let .opaque(useNewStyle):
            content.background(
                getOpaqueBackground(useNewStyle: useNewStyle)
            )
            .clipShape(Squircle.default())
            .hShadow()
        case let .caution(useNewStyle):
            content.background(
                getCautionBackground(useNewStyle: useNewStyle)
            )
            .border(
                useNewStyle ? Color(UIColor.brandNew(.primaryBorderColor)) : Color(UIColor.brand(.primaryBorderColor))
            )
        }
    }

    @hColorBuilder
    private func getOpaqueBackground(useNewStyle: Bool) -> some hColor {
        if useNewStyle {
            hGrayscaleColorNew.greyScale100
        } else {
            hBackgroundColor.tertiary
        }
    }

    @hColorBuilder
    private func getCautionBackground(useNewStyle: Bool) -> some hColor {
        if useNewStyle {
            hYellowColorNew.yellow600
        } else {
            hTintColor.yellowTwo
        }
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
    @Environment(\.hUseNewStyle) var useNewStyle
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
            .modifier(getProperContainerStyle())
        }
        .frame(maxWidth: .infinity)
    }
    
    func getProperContainerStyle() -> hSectionContainerStyle{
        switch containerStyle {
        case .caution:
            return .caution(useNewDesign: useNewStyle)
        case .opaque:
            return .opaque(useNewDesign: useNewStyle)
        case .transparent:
            return .transparent
        }
    }
}

public struct hSection<Header: View, Content: View, Footer: View>: View {
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    @Environment(\.hUseNewStyle) var hUseNewStyle

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
                    if hUseNewStyle {
                        header
                            .environment(\.defaultHTextStyleNew, .title1)
                    } else {
                        header
                            .environment(\.defaultHTextStyle, .title3)
                    }
                }
                .foregroundColor(hSection<Header, Content, Footer>.returnLabelColorPrimary(useNewStyle: hUseNewStyle))
                .padding(.bottom, 10)
            }
            hSectionContainer {
                content
            }
            if footer != nil {
                VStack(alignment: .leading) {
                    if hUseNewStyle {
                        footer
                            .environment(\.defaultHTextStyleNew, .footnote)
                    } else {
                        footer
                            .environment(\.defaultHTextStyle, .footnote)
                    }
                }
                .foregroundColor(hSection<Header, Content, Footer>.returnLabelColorSecondary(useNewStyle: hUseNewStyle))
                .padding([.leading, .trailing], 15)
                .padding(.top, 10)
            }
        }
        .frame(maxWidth: .infinity)
        .padding([.leading, .trailing], horizontalSizeClass == .regular ? 60 : 15)
        .padding([.top, .bottom], hUseNewStyle ? 0 : 15)
    }

    @hColorBuilder
    static func returnLabelColorPrimary(useNewStyle: Bool) -> some hColor {
        if useNewStyle {
            hLabelColorNew.primary
        } else {
            hLabelColor.primary
        }
    }

    @hColorBuilder
    static func returnLabelColorSecondary(useNewStyle: Bool) -> some hColor {
        if useNewStyle {
            hLabelColorNew.secondary
        } else {
            hLabelColor.secondary
        }
    }

    /// removes hSection bottom padding
    public var withoutBottomPadding: some View {
        self.padding(.bottom, hUseNewStyle ? 0 : -15)
    }
    
    /// removes hSection leading and trailing padding
    public var withoutHorizontalPadding: some View {
        self
            .padding(.leading, horizontalSizeClass == .regular ? -60 : -15)
            .padding(.trailing, horizontalSizeClass == .regular ? -60 : -15)
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
