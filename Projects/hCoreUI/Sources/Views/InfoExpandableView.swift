import SwiftUI

public struct InfoExpandableView: View {
    @State var height: CGFloat = 0
    @State var selectedFields: [String] = []
    var title: String
    var text: String
    var onMarkDownClick: ((URL) -> Void)?

    public init(
        title: String,
        text: String,
        onMarkDownClick: ((URL) -> Void)? = nil
    ) {
        self.title = title
        self.text = text
        self.onMarkDownClick = onMarkDownClick
    }

    public var body: some View {
        hSection {
            hRow {
                hText(title)
                    .fixedSize(horizontal: false, vertical: true)
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
                        CustomTextViewRepresentable(
                            text: text,
                            fixedWidth: UIScreen.main.bounds.width - 32,
                            fontSize: .body,
                            height: $height
                        ) { url in
                            onMarkDownClick?(url)
                        }
                        .frame(height: height)
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
