import Foundation
import SwiftUI

public struct StatusCard<MainContent, BottomContent>: View
where MainContent: View, BottomContent: View {
    var onSelected: (() -> Void)?
    let mainContent: MainContent?
    let title: String?
    let subTitle: String?
    let bottomComponent: (() -> BottomContent)?
    @Environment(\.hCardWithoutSpacing) var cardWithoutSpacing
    @Environment(\.hCardWithDivider) var withDivider
    let accessibilityWithoutCombinedElements: Bool

    public init(
        onSelected: (() -> Void)? = nil,
        mainContent: MainContent? = nil,
        title: String? = nil,
        subTitle: String? = nil,
        accessibilityWithoutCombinedElements: Bool = false,
        bottomComponent: (() -> BottomContent)?
    ) {
        self.onSelected = onSelected
        self.mainContent = mainContent
        self.title = title
        self.subTitle = subTitle
        self.bottomComponent = bottomComponent
        self.accessibilityWithoutCombinedElements = accessibilityWithoutCombinedElements
    }

    public var body: some View {
        if accessibilityWithoutCombinedElements {
            mainView
        } else {
            mainView
                .accessibilityElement(children: .combine)
                .accessibilityRemoveTraits(.isHeader)
        }
    }

    private var mainView: some View {
        VStack(alignment: .leading, spacing: 0) {
            hRow {
                mainContent
            }
            .verticalPadding(0)
            .padding(.bottom, cardWithoutSpacing ? 0 : .padding16)
            VStack(alignment: .leading, spacing: 0) {
                if let title = title {
                    hText(title)
                        .foregroundColor(hTextColor.Opaque.primary)
                }
                if let subTitle = subTitle {
                    hText(subTitle, style: .label)
                        .foregroundColor(hTextColor.Opaque.secondary)
                }
            }
            .padding([.horizontal], .padding16)

            if withDivider, bottomComponent != nil {
                hRowDivider()
                    .foregroundColor(hSurfaceColor.Translucent.primary)
                Spacer().frame(height: .padding16)
            }

            Spacer().frame(height: cardWithoutSpacing ? 0 : .padding16)
            if let bottomComponent {
                bottomComponent()
                    .padding(.horizontal, .padding16)
            }
        }
        .padding(.top, .padding16)
        .padding(.bottom, bottomComponent == nil ? 0 : .padding16)
        .onTapGesture {
            if let onSelected = onSelected {
                onSelected()
            }
        }
        .accessibilityAddTraits(onSelected != nil ? .isButton : [])
        .modifier(StatusCardBackgroundModifier())
    }
}

struct StatusCardBackgroundModifier: ViewModifier {
    @Environment(\.hCardBackgroundColor) var backgroundColor

    func body(content: Content) -> some View {
        if backgroundColor == .default {
            content
                .background(
                    Rectangle()
                        .fill(hSurfaceColor.Opaque.primary)
                )
                .cornerRadius(.cornerRadiusXL)
        } else {
            content
                .background(
                    Rectangle()
                        .fill(hBackgroundColor.primary)
                )
                .cornerRadius(.cornerRadiusXXL)
                .shadow(color: Color(red: 0.07, green: 0.07, blue: 0.07).opacity(0.05), radius: 5, x: 0, y: 4)

                .shadow(color: Color(red: 0.07, green: 0.07, blue: 0.07).opacity(0.1), radius: 1, x: 0, y: 2)

                .overlay(
                    RoundedRectangle(cornerRadius: .cornerRadiusXXL)
                        .inset(by: 0.5)
                        .stroke(hBorderColor.primary, lineWidth: 1)
                )
        }
    }
}

#Preview("CardComponent") {
    VStack {
        Spacer()
        StatusCard(
            onSelected: {},
            mainContent: Text("T"),
            title: "TITLE",
            subTitle: "SUBTITLE",
            bottomComponent: {
                Text("BOTTOM COMPONENT")
            }
        )
        Spacer()
    }
    .background(Color.gray)
}

#Preview("FCardComponent") {
    VStack {
        Spacer()
        StatusCard(
            onSelected: {},
            mainContent: Text("T"),
            title: "TITLE",
            subTitle: "SUBTITLE",
            bottomComponent: {
                Text("BOTTOM COMPONENT")
            }
        )
        Spacer()
    }
    .background(Color.gray)
}

public enum CardBackgroundColor: Sendable {
    case `default`
    case light
}

extension EnvironmentValues {
    @Entry public var hCardWithoutSpacing: Bool = false
    @Entry public var hCardWithDivider: Bool = false
    @Entry public var hCardBackgroundColor: CardBackgroundColor = CardBackgroundColor.default
}

extension View {
    public var hCardWithoutSpacing: some View {
        environment(\.hCardWithoutSpacing, true)
    }
}

extension View {
    public var hCardWithDivider: some View {
        environment(\.hCardWithDivider, true)
    }
}

extension View {
    public func hCardBackgroundColor(_ color: CardBackgroundColor) -> some View {
        environment(\.hCardBackgroundColor, color)
    }
}
