import Foundation
import SwiftUI
import hCore

public struct CardComponent<Content>: View where Content: View {
    let title: String?
    let subTitle: String?
    let text: String?
    var mainContent: Content?
    let onSelected: () -> Void

    public init(
        onSelected: @escaping () -> Void,
        mainContent: Content? = nil,
        title: String? = nil,
        subTitle: String? = nil,
        text: String? = nil
    ) {
        self.onSelected = onSelected
        self.mainContent = mainContent
        self.title = title
        self.subTitle = subTitle
        self.text = text
    }

    public var body: some View {
        VStack {
            VStack(alignment: .leading, spacing: 0) {
                HStack(alignment: .top, spacing: 0) {
                    mainContent
                    hText(title ?? "")
                        .padding(.leading, 16)
                    Spacer()
                    hCoreUIAssets.chevronRight.view
                }
                .padding([.leading, .trailing, .top], 16)
                Spacer().frame(height: 20)
                SwiftUI.Divider()
                    .padding([.leading, .trailing], 16)
                hText(
                    text ?? "",
                    style: .footnote
                )
                .foregroundColor(hLabelColor.secondary)
                .fixedSize(horizontal: false, vertical: true)
                .padding(16)
            }
            .onTapGesture {
                onSelected()
            }
            .background(
                RoundedRectangle(cornerRadius: 10)
                    .fill(hBackgroundColor.primary)
                    .hShadow()
            )
            .padding([.leading, .trailing], 16)
            .padding([.top, .bottom], 8)
        }
    }
}
