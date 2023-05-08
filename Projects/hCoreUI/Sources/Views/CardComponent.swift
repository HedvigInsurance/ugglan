import Foundation
import SwiftUI
import hCore

public struct CardComponent<Content, Content2>: View where Content: View, Content2: View {
    var onSelected: (() -> Void)?
    let mainContent: Content?
    let topTitle: String?
    let title: String?
    let subTitle: String?
    let bottomComponent: () -> Content2

    public init(
        onSelected: (() -> Void)? = nil,
        mainContent: Content? = nil,
        title: String? = nil,
        subTitle: String? = nil,
        topTitle: String? = nil,
        bottomComponent: @escaping () -> Content2
    ) {
        self.onSelected = onSelected
        self.mainContent = mainContent
        self.title = title
        self.topTitle = topTitle
        self.subTitle = subTitle
        self.bottomComponent = bottomComponent
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack(alignment: .top) {
                mainContent
                if let topTitle = topTitle {
                    hText(topTitle)
                        .padding(.leading, 16)
                }
                Spacer()
                hCoreUIAssets.chevronRight.view
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
            SwiftUI.Divider()
            Spacer().frame(height: 16)
            bottomComponent()
                .padding([.leading, .trailing], 16)
        }
        .padding([.top, .bottom], 16)
        .background(
            Squircle.default()
                .fill(hBackgroundColor.tertiary)
                .hShadow()
        )
        .onTapGesture {
            if let onSelected = onSelected {
                onSelected()
            }
        }
    }
}
