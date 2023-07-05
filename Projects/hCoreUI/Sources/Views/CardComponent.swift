import Foundation
import SwiftUI
import hCore

public struct CardComponent<MainContent, BottomContent, MiddleContent>: View
where MainContent: View, BottomContent: View, MiddleContent: View {
    @Environment(\.hUseNewStyle) var hUseNewStyle
    @Environment(\.hCardComponentOptions) var options

    var onSelected: (() -> Void)?
    let mainContent: MainContent?
    let middleContent: MiddleContent?
    let title: String?
    let subTitle: String?
    let bottomComponent: () -> BottomContent

    public init(
        onSelected: (() -> Void)? = nil,
        mainContent: MainContent? = nil,
        title: String? = nil,
        middleContent: MiddleContent? = nil,
        subTitle: String? = nil,
        bottomComponent: @escaping () -> BottomContent
    ) {
        self.onSelected = onSelected
        self.mainContent = mainContent
        self.title = title
        self.middleContent = middleContent
        self.subTitle = subTitle
        self.bottomComponent = bottomComponent
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack(alignment: .top, spacing: 16) {
                mainContent
                middleContent
                if !options.hideArrow {
                    Spacer()
                    hCoreUIAssets.chevronRight.view
                }
            }
            .padding(.horizontal, 16)
            if let title = title {
                Spacer().frame(height: 20)
                hText(title)
                    .padding([.leading, .trailing], 16)
            }
            if let subTitle = subTitle {
                Spacer().frame(height: 4)
                hText(subTitle, style: .caption1)
                    .foregroundColor(hLabelColor.secondary)
                    .padding([.leading, .trailing], 16)
            }
            Spacer().frame(height: 20)
            if options.paddingOnDivider {
                SwiftUI.Divider()
                    .padding(.horizontal, 16)
            } else {
                SwiftUI.Divider()
            }
            Spacer().frame(height: 16)
            bottomComponent()
                .padding([.leading, .trailing], 16)
        }
        .padding([.top, .bottom], 16)
        .background(
            getBackground
        )
        .onTapGesture {
            if let onSelected = onSelected {
                onSelected()
            }
        }
    }

    @ViewBuilder
    var getBackground: some View {
        if hUseNewStyle {
            Squircle.default()
                .fill(hBackgroundColorNew.opaqueOne)
        } else {
            Squircle.default()
                .fill(hBackgroundColor.tertiary)
                .hShadow()
        }
    }
}

public enum hCardComponentOptions: Hashable {
    case hideArrow
    case paddingOnDivider
}

extension Set where Element == hCardComponentOptions {

    var hideArrow: Bool {
        self.contains(.hideArrow)
    }

    var paddingOnDivider: Bool {
        self.contains(.paddingOnDivider)
    }
}

private struct EnvironmentHCardComponentOptions: EnvironmentKey {
    static let defaultValue: Set<hCardComponentOptions> = []
}

extension EnvironmentValues {
    public var hCardComponentOptions: Set<hCardComponentOptions> {
        get { self[EnvironmentHCardComponentOptions.self] }
        set { self[EnvironmentHCardComponentOptions.self] = newValue }
    }
}

extension View {
    public func hCardComponentOptions(_ options: Set<hCardComponentOptions>) -> some View {
        self.environment(\.hCardComponentOptions, options)
    }
}
