import SwiftUI

public struct CheckBoxComponent: View {
    @State var isSelected = ""
    var title = ""
    var selectedValue: (String) -> Void

    public init(
        title: String,
        selectedValue: @escaping (String) -> Void
    ) {
        self.title = title
        self.selectedValue = selectedValue
    }

    public var body: some View {
        hSection {
            hRow {
                displayContent(displayName: title)
            }
            .noSpacing()
            .onTapGesture {
                isSelected = title
                selectedValue(title)
            }
            .padding(16)
        }
        .padding(.bottom, -4)
    }

    @ViewBuilder
    func displayContent(displayName: String) -> some View {
        HStack(spacing: 12) {
            Image(uiImage: hCoreUIAssets.bigPillowHome.image)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 48, height: 48)
            hText(displayName, style: .body)
                .foregroundColor(hTextColor.primary)
            Spacer()
            Circle()
                .strokeBorder(
                    getBorderColor(currentItem: displayName),
                    lineWidth: displayName == isSelected ? 0 : 1.5
                )
                .background(Circle().foregroundColor(retColor(currentItem: displayName)))
                .frame(width: 28, height: 28)
        }
    }

    @hColorBuilder
    func getBorderColor(currentItem: String) -> some hColor {
        if currentItem == isSelected {
            hTextColor.primary
        } else {
            hBorderColor.opaqueTwo
        }
    }

    @hColorBuilder
    func retColor(currentItem: String) -> some hColor {
        if currentItem == isSelected {
            hTextColor.primary
        } else {
            hFillColor.opaqueOne
        }
    }
}

struct CheckBoxComponent_Previews: PreviewProvider {
    static var previews: some View {
        CheckBoxComponent(title: "", selectedValue: { val in })
    }
}
