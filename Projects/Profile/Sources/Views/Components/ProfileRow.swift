import Presentation
import SwiftUI
import hCore
import hCoreUI
import hGraphQL

struct ProfileRow: View {
    @PresentableStore var store: ProfileStore

    let row: ProfileRowType

    init(
        row: ProfileRowType
    ) {
        self.row = row
    }

    public var body: some View {
        if #available(iOS 16.0, *) {
            NavigationLink(value: row.profileViewType) {
                hRow {
                    HStack(spacing: 16) {
                        Image(uiImage: row.icon)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 24, height: 24)
                        hText(row.title)
                        Spacer()
                    }
                }
                .withChevronAccessory
            }
        } else {
            EmptyView()
        }
    }
}
