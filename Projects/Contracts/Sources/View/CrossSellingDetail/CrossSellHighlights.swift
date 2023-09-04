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
                        uiImage: hCoreUIAssets.tick.image
                    )
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(
                        width: 24,
                        height: 24
                    )
                    VStack(alignment: .leading, spacing: 4) {
                        hText(highlight.title, style: .body)
                            .fixedSize(horizontal: false, vertical: true)
                        hText(
                            highlight.description,
                            style: .subheadline
                        )
                        .fixedSize(horizontal: false, vertical: true)
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
