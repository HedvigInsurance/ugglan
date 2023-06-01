import SwiftUI
import hCore

public struct NoticeComponent: View {
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
                .foregroundColor(hBlueColorNew.blue900)
                .padding(.leading, 9)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding([.top, .bottom], 12)
        .padding([.leading, .trailing], 16)
        .background(
            Squircle.default()
                .fill(hBlueColorNew.blue200)
        )
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding([.leading, .trailing], 16)
    }
}

struct NoticeComponent_Previews: PreviewProvider {
    static var previews: some View {
        NoticeComponent(text: L10n.changeAddressCoverageInfoText)
    }
}
