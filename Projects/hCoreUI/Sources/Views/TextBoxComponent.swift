import Foundation
import SwiftUI
import hCore

public struct TextBoxComponent<MainContent>: View where MainContent: View {
    var onSelected: (() -> Void)?
    let mainContent: MainContent?
    let topTitle: String?
    let subTitle: String?

    public init(
        onSelected: (() -> Void)? = nil,
        mainContent: MainContent? = nil,
        subTitle: String? = nil,
        topTitle: String? = nil
    ) {
        self.onSelected = onSelected
        self.mainContent = mainContent
        self.topTitle = topTitle
        self.subTitle = subTitle
    }

    public var body: some View {
        HStack(alignment: .top) {
            mainContent
            VStack {
                if let topTitle = topTitle {
                    hText(topTitle, style: .body)
                        .foregroundColor(hTextColorNew.primary)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.leading, 16)
                }
                if let subTitle = subTitle {
                    hText(subTitle, style: .body)
                        .foregroundColor(hTextColorNew.secondary)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.leading, 16)
                }
            }
            Spacer()
        }
        .padding(16)
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
