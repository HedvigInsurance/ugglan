import Foundation
import SwiftUI
import hCore
import hCoreUI
import hGraphQL

struct CrossSellHightlights: View {
    let info: CrossSellInfo

    var body: some View {
        hSection(header: hText("Highlights")) {
            ForEach(info.highlights, id: \.title) { highlight in
                HStack {
                    hText(highlight.title)
                }
            }
        }
        .sectionContainerStyle(.transparent)
    }
}
