import Foundation
import SwiftUI
import hCore

public struct CardComponent<MainContent, BottomContent>: View where MainContent: View, BottomContent: View {
    var onSelected: (() -> Void)?
    let mainContent: MainContent?
    let topTitle: String?
    let title: String?
    let subTitle: String?
    let bottomComponent: () -> BottomContent

    public init(
        onSelected: (() -> Void)? = nil,
        mainContent: MainContent? = nil,
        title: String? = nil,
        subTitle: String? = nil,
        topTitle: String? = nil,
        bottomComponent: @escaping () -> BottomContent
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
            HStack(alignment: .center) {
                mainContent
                if let topTitle = topTitle {
                    hText(topTitle)
                        .padding(.leading, 16)
                }
                Spacer()
                hCoreUIAssets.chevronRight.view
                    .resizable()
                    .frame(width: 16, height: 16)
                    .foregroundColor(hTextColorNew.secondary)
            }
            .padding(.horizontal, 16)
            .padding(.bottom, 16)
            VStack(alignment: .leading, spacing: 0) {
                if let title = title {
                    hText(title)
                }
                hText(subTitle ?? " ", style: .standardSmall)
                    .foregroundColor(hTextColorNew.secondary)

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
                .fill(hFillColorNew.opaqueOne)
                .hShadow()
        )
        .onTapGesture {
            if let onSelected = onSelected {
                onSelected()
            }
        }
    }
}

struct CardComponent_Previews: PreviewProvider {
    static var previews: some View {
        VStack {
            Spacer()
            CardComponent(
                onSelected: {

                },
                mainContent: Text("T"),  //ClaimPills(claim: claim),
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
