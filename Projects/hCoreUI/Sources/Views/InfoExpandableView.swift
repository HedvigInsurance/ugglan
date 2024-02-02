import SwiftUI

public struct InfoExpandableView: View {
    @State var height: CGFloat = 0
    @State var selectedFields: [String] = []
    var title: String
    var text: String
    var questionClicked: (() -> Void)?
    var onMarkDownClick: ((URL) -> Void)?

    public init(
        title: String,
        text: String,
        questionClicked: (() -> Void)? = nil,
        onMarkDownClick: ((URL) -> Void)? = nil
    ) {
        self.title = title
        self.text = text
        self.questionClicked = questionClicked
        self.onMarkDownClick = onMarkDownClick
    }

    public var body: some View {
        hSection {
            hRow {
                hText(title)
                    .fixedSize(horizontal: false, vertical: true)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            .withCustomAccessory({
                withAnimation(.spring()) {
                    Image(
                        uiImage: selectedFields.contains(title)
                            ? hCoreUIAssets.minusSmall.image : hCoreUIAssets.plusSmall.image
                    )
                }
                .transition(.opacity)
            })
            .onTap {
                withAnimation(.spring) {
                    if !selectedFields.contains(title) {
                        questionClicked?()
                        selectedFields.append(title)
                    } else {
                        if let index = selectedFields.firstIndex(of: title) {
                            selectedFields.remove(at: index)
                        }
                    }
                }
            }
            .hWithoutDivider
            .contentShape(Rectangle())
            if selectedFields.contains(title) {
                VStack(alignment: .leading) {
                    hRow {
                        CustomTextViewRepresentable(
                            config: .init(
                                text: text,
                                fixedWidth: UIScreen.main.bounds.width - 56,
                                fontStyle: .standard,
                                color: hTextColor.secondary,
                                linkColor: hTextColor.primary,
                                linkUnderlineStyle: .single,
                                onUrlClicked: { url in
                                    onMarkDownClick?(url)

                                }
                            ),
                            height: $height
                        )
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
        InfoExpandableView(
            title: "long longlong long long long title",
            text: "long long long long long long long long long long"
        )
    }
}
