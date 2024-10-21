import Foundation
import SwiftUI
import hCore

public enum StatusCardStyle {
    case `default`
    case primary
}

public struct StatusCard<MainContent, BottomContent>: View
where MainContent: View, BottomContent: View {
    var onSelected: (() -> Void)?
    let mainContent: MainContent?
    let title: String?
    let subTitle: String?
    let bottomComponent: () -> BottomContent
    let style: StatusCardStyle
    @Environment(\.hCardWithoutSpacing) var cardWithoutSpacing

    public init(
        onSelected: (() -> Void)? = nil,
        mainContent: MainContent? = nil,
        title: String? = nil,
        subTitle: String? = nil,
        bottomComponent: @escaping () -> BottomContent,
        style: StatusCardStyle = .default
    ) {
        self.onSelected = onSelected
        self.mainContent = mainContent
        self.title = title
        self.subTitle = subTitle
        self.bottomComponent = bottomComponent
        self.style = style
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            hRow {
                HStack(alignment: .center) {
                    mainContent
                    Spacer()
                }
            }
            .verticalPadding(0)
            .padding(.bottom, cardWithoutSpacing ? 0 : .padding16)
            VStack(alignment: .leading, spacing: 0) {
                if let title = title {
                    hText(title)
                        .foregroundColor(hTextColor.Opaque.primary)
                }
                hText(subTitle ?? " ", style: .label)
                    .foregroundColor(hTextColor.Opaque.secondary)

            }
            .padding(.horizontal, .padding16)
            Spacer().frame(height: cardWithoutSpacing ? 0 : 16)
            bottomComponent()
                .padding(.horizontal, .padding16)
        }
        .padding(.vertical, .padding16)
        .background(
            background
        )
        .onTapGesture {
            if let onSelected = onSelected {
                onSelected()
            }
        }
    }

    @ViewBuilder
    private var background: some View {
        if style == .primary {
            RoundedRectangle(cornerRadius: .cornerRadiusXL)
                .fill(hBackgroundColor.primary)
                .overlay(
                    RoundedRectangle(cornerRadius: .cornerRadiusL)
                        .strokeBorder(hBorderColor.primary, lineWidth: 1)
                        .hShadow(type: .custom(opacity: 0.05, radius: 5, xOffset: 0, yOffset: 4))
                        .hShadow(type: .custom(opacity: 0.1, radius: 1, xOffset: 0, yOffset: 2))
                )
        } else {
            RoundedRectangle(cornerRadius: .cornerRadiusXL)
                .fill(hSurfaceColor.Opaque.primary)
        }
    }
}

struct CardComponent_Previews: PreviewProvider {
    static var previews: some View {
        VStack {
            Spacer()
            StatusCard(
                onSelected: {

                },
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
}

struct FCardComponent_Previews: PreviewProvider {
    static var previews: some View {
        VStack {
            Spacer()
            StatusCard(
                onSelected: {

                },
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
}

private struct EnvironmentHCardWithoutSpacing: EnvironmentKey {
    static let defaultValue = false
}

extension EnvironmentValues {
    public var hCardWithoutSpacing: Bool {
        get { self[EnvironmentHCardWithoutSpacing.self] }
        set { self[EnvironmentHCardWithoutSpacing.self] = newValue }
    }
}

extension View {
    public var hCardWithoutSpacing: some View {
        self.environment(\.hCardWithoutSpacing, true)
    }
}
