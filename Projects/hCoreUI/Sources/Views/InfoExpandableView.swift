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

    @ViewBuilder
    public var body: some View {
        let isSelected = selectedFields.contains(title)
        hSection {
            hRow {
                hText(title)
                    .fixedSize(horizontal: false, vertical: true)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            .withCustomAccessory({
                ZStack {
                    Image(
                        uiImage: hCoreUIAssets.minus.image
                    )
                    .rotationEffect(isSelected ? Angle(degrees: 360) : Angle(degrees: 270))
                    Image(
                        uiImage: hCoreUIAssets.minus.image
                    )
                    .rotationEffect(isSelected ? Angle(degrees: 360) : Angle(degrees: 180))
                }
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
                        MarkdownView(
                            config: .init(
                                text: text,
                                fontStyle: .standard,
                                color: hTextColor.Opaque.secondary,
                                linkColor: hTextColor.Opaque.primary,
                                linkUnderlineStyle: .single
                            ) { url in
                                onMarkDownClick?(url)
                            }
                        )
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
        VStack {
            InfoExpandableView(
                title: "long longlong long long long title",
                text:
                    "long long long long long long long long long longng long long long long long long long longng long long long long long long long longng long long long long long long long longng long long long long long long long longng long long long long long long long longng long long long long long long long longng long long long long long long long longng long long long long long long long longng long long long long long long long longng long long long long long long long long"
            )
            Spacer()
        }
    }
}
