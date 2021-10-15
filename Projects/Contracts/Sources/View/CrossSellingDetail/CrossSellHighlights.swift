import Foundation
import SwiftUI
import hCore
import hCoreUI
import hGraphQL

struct CrossSellHightlights: View {
    let info: CrossSellInfo

    var body: some View {
        hSection {
            ForEach(info.highlights, id: \.title) { highlight in
                HStack(alignment: .top, spacing: 18) {
                    Image(
                        uiImage: hCoreUIAssets.checkmark.image
                    )
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(
                        width: 24,
                        height: 24
                    )
                    VStack(alignment: .leading, spacing: 4) {
                        hText(highlight.title, style: .body)
                        hText(
                            highlight.description,
                            style: .subheadline
                        )
                        .foregroundColor(hLabelColor.secondary)
                    }
                }
                .frame(
                    maxWidth: .infinity,
                    alignment: .leading
                )
                .padding(.bottom, 24)
            }
        }
        .padding(.bottom, -24)
        .sectionContainerStyle(.transparent)
    }
}
