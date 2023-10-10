import Foundation
import SwiftUI
import hCore

public struct CardComponent<MainContent, BottomContent>: View
where MainContent: View, BottomContent: View {
    var onSelected: (() -> Void)?
    let mainContent: MainContent?
    let title: String?
    let subTitle: String?
    let bottomComponent: () -> BottomContent

    public init(
        onSelected: (() -> Void)? = nil,
        mainContent: MainContent? = nil,
        title: String? = nil,
        subTitle: String? = nil,
        bottomComponent: @escaping () -> BottomContent
    ) {
        self.onSelected = onSelected
        self.mainContent = mainContent
        self.title = title
        self.subTitle = subTitle
        self.bottomComponent = bottomComponent
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack(alignment: .center) {
                mainContent
                Spacer()
                if onSelected != nil {
                    hCoreUIAssets.chevronRight.view
                        .resizable()
                        .frame(width: 16, height: 16)
                        .foregroundColor(hTextColor.secondary)
                }
            }
            .padding(.horizontal, 16)
            .padding(.bottom, 16)
            VStack(alignment: .leading, spacing: 0) {
                if let title = title {
                    hText(title)
                }
                hText(subTitle ?? " ", style: .standardSmall)
                    .foregroundColor(hTextColor.secondary)

            }
            .padding([.leading, .trailing], 16)

            Spacer().frame(height: 20)
            SwiftUI.Divider()
            Spacer().frame(height: 16)
            bottomComponent()
                .padding([.leading, .trailing], 16)
        }
        .padding(.vertical, 16)
        .background(
            Squircle.default()
                .fill(hFillColor.opaqueOne)
        )
        .onTapGesture {
            if let onSelected = onSelected {
                onSelected()
            }
        }
    }

    @ViewBuilder
    var getBackground: some View {
        Squircle.default()
            .fill(hFillColor.opaqueOne)
    }
}

struct CardComponent_Previews: PreviewProvider {
    static var previews: some View {
        VStack {
            Spacer()
            CardComponent(
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
            CardComponent(
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
