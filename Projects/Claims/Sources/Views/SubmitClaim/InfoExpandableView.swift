import SwiftUI
import hCoreUI

struct InfoExpandableView: View {
    @State var selectedFields: [String] = []
    var title: String
    var text: String

    init(
        title: String,
        text: String
    ) {
        self.title = title
        self.text = text
    }

    var body: some View {
        hSection {
            hRow {
                hText(title)
                    .lineLimit(1)
            }
            .withCustomAccessory({
                Spacer()
                Image(
                    uiImage: selectedFields.contains(title)
                        ? hCoreUIAssets.minusSmall.image : hCoreUIAssets.plusSmall.image
                )
                .transition(.opacity.animation(.easeOut))
            })
            .onTap {
                if !selectedFields.contains(title) {
                    selectedFields.append(title)
                } else {
                    if let index = selectedFields.firstIndex(of: title) {
                        selectedFields.remove(at: index)
                    }
                }
            }
            .hWithoutDivider
            .contentShape(Rectangle())
            if selectedFields.contains(title) {
                VStack(alignment: .leading) {
                    hRow {
                        hText(text)
                            .fixedSize(horizontal: false, vertical: true)
                            .foregroundColor(hTextColor.secondary)
                    }
                    .verticalPadding(0)
                    .padding(.bottom, 24)
                }
            }
        }
    }
}

struct InfoExpandableView_Previews: PreviewProvider {
    static var previews: some View {
        InfoExpandableView(title: "title", text: "text")
    }
}
