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
            hSection {
                HStack(alignment: .center) {
                    mainContent
                    Spacer()
                }
            }
            .sectionContainerStyle(.transparent)
            .padding(.bottom, .padding16)
            VStack(alignment: .leading, spacing: 0) {
                if let title = title {
                    hText(title)
                        .foregroundColor(hTextColor.Opaque.primary)
                }
                hText(subTitle ?? " ", style: .standardSmall)
                    .foregroundColor(hTextColor.Opaque.secondary)

            }
            .padding(.horizontal, .padding16)

            Spacer().frame(height: 20)
            SwiftUI.Divider()
            Spacer().frame(height: .padding16)
            bottomComponent()
                .padding(.horizontal, .padding16)
        }
        .padding(.vertical, .padding16)
        .background(
            Squircle.default()
                .fill(hSurfaceColor.Translucent.secondary)
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
