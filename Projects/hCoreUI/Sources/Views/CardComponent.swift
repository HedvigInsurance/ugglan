import Combine
import Foundation
import SwiftUI
import hCore

public enum CardComponentOptions: Hashable {
    case withoutDividerPadding
    case hideArrow
}

extension Set where Element == CardComponentOptions {
    var withoutDividerPadding: Bool {
        self.contains(.withoutDividerPadding)
    }

    var hideArrow: Bool {
        self.contains(.hideArrow)
    }
}

private struct EnvironmentCardComponentOptions: EnvironmentKey {
    static let defaultValue: Set<CardComponentOptions> = []
}

extension EnvironmentValues {
    public var cardComponentOptions: Set<CardComponentOptions> {
        get { self[EnvironmentCardComponentOptions.self] }
        set { self[EnvironmentCardComponentOptions.self] = newValue }
    }
}

extension View {
    public func cardComponentOptions(_ options: Set<CardComponentOptions>) -> some View {
        self.environment(\.cardComponentOptions, options)
    }
}

public struct CardComponent<MainContent, BottomContent, TopSubContent>: View
where MainContent: View, BottomContent: View, TopSubContent: View {

    @Environment(\.cardComponentOptions) var options
    var onSelected: (() -> Void)?
    let mainContent: MainContent?
    let topTitle: String?
    let topSubTitle: (() -> TopSubContent)?
    let title: String?
    let subTitle: String?
    let bottomComponent: () -> BottomContent
    let isNew: Bool?

    public init(
        onSelected: (() -> Void)? = nil,
        mainContent: MainContent? = nil,
        title: String? = nil,
        subTitle: String? = nil,
        topTitle: String? = nil,
        topSubTitle: (() -> TopSubContent)? = nil,
        bottomComponent: @escaping () -> BottomContent,
        isNew: Bool? = false
    ) {
        self.onSelected = onSelected
        self.mainContent = mainContent
        self.title = title
        self.topTitle = topTitle
        self.subTitle = subTitle
        self.topSubTitle = topSubTitle
        self.bottomComponent = bottomComponent
        self.isNew = isNew
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack(alignment: .top) {
                mainContent
                VStack(alignment: .leading) {
                    if let topTitle = topTitle {
                        hText(topTitle, style: .body)
                    }
                    if let topSubTitle = topSubTitle {
                        topSubTitle()
                    }
                }
                .padding(.leading, 16)
                if !options.hideArrow {
                    Spacer()
                    hCoreUIAssets.chevronRight.view
                }
            }
            .padding([.leading, .trailing], 16)
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
            if options.withoutDividerPadding {
                SwiftUI.Divider()
            } else {
                SwiftUI.Divider()
                    .padding([.leading, .trailing], 16)
            }
            Spacer().frame(height: 16)
            bottomComponent()
                .padding([.leading, .trailing], 16)
        }
        .padding([.top, .bottom], 16)
        .background(
            Squircle.default()
                .fill(setBackgroundColor)
                .hShadow()
        )
        .onTapGesture {
            if let onSelected = onSelected {
                onSelected()
            }
        }
    }

    @hColorBuilder
    var setBackgroundColor: some hColor {
        if isNew ?? false {
            hGrayscaleColorNew.greyScale100
        } else {
            hBackgroundColor.tertiary
        }
    }
}
