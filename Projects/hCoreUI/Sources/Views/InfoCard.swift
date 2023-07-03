import SwiftUI
import hCore

public struct InfoCard: View {
    let text: String

    public init(
        text: String
    ) {
        self.text = text
    }

    public var body: some View {
        HStack(alignment: .top, spacing: 0) {
            Image(uiImage: hCoreUIAssets.infoSmall.image)
                .foregroundColor(hBlueColorNew.blue600)

            hTextNew(text, style: .footnote)
                .foregroundColor(hLabelColorNew.signalBlue)
                .padding(.leading, 9)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding([.top, .bottom], 12)
        .padding([.leading, .trailing], 16)
        .background(
            Squircle.default()
                .fill(hBackgroundColorNew.signalBlueBackground)
                .overlay(
                    RoundedRectangle(cornerRadius: .defaultCornerRadiusNew)
                        .strokeBorder(hLabelColorNew.translucentBorder, lineWidth: 0.5)
                )
        )
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding([.leading, .trailing], 16)
    }
}

struct InfoCard_Previews: PreviewProvider {
    static var previews: some View {
        InfoCard(text: L10n.changeAddressCoverageInfoText)
    }
}
