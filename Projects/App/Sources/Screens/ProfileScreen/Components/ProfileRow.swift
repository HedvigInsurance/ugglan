import Presentation
import SwiftUI
import hCore
import hCoreUI
import hGraphQL

struct ProfileRow: View {
    @PresentableStore var store: ProfileStore

    let row: ProfileRowType
    let subtitle: String?

    init(
        row: ProfileRowType,
        subtitle: String? = nil
    ) {
        self.row = row
        self.subtitle = subtitle
    }

    public var body: some View {
        hRow {
            HStack(spacing: 16) {
                Image(uiImage: row.icon)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: row.imageSize, height: row.imageSize)
                    .padding(row.paddings)
                VStack(alignment: .leading, spacing: 2) {
                    hText(row.title)
                    if let subtitle = subtitle, subtitle != "" {
                        hText(subtitle, style: .footnote).foregroundColor(hLabelColor.secondary)
                    }
                }
            }
            .padding(0)
        }
        .withCustomAccessory({
            Spacer()
            StandaloneChevronAccessory()
        })
        .verticalPadding(12)
        .onTap {
            store.send(row.action)
        }
    }
}
