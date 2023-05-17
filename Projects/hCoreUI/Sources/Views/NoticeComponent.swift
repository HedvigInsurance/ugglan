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
        HStack(alignment: .top) {
            Image(uiImage: hCoreUIAssets.infoSmall.image)
                .foregroundColor(hTintColorNew.blue600)

            hText(text, style: .body)
                .foregroundColor(hTintColorNew.blue900)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding([.top, .bottom], 12)
        .padding([.leading, .trailing], 16)
        .background(
            Squircle.default()
                .fill(hTintColorNew.blue200)
        )
        //        .padding([.leading, .trailing], 16)
    }
}

struct NoticeComponent_Previews: PreviewProvider {
    static var previews: some View {
        NoticeComponent(text: L10n.changeAddressCoverageInfoText)
    }
}
