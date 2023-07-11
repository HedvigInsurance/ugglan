import SwiftUI
import hCore

public struct InfoCard: View {
    let text: String
    let type: InfoCardType

    public init(
        text: String,
        type: InfoCardType
    ) {
        self.text = text
        self.type = type
    }

    public var body: some View {
        HStack(alignment: .top, spacing: 0) {
            Image(uiImage: hCoreUIAssets.infoIconFilled.image)
                .foregroundColor(hSignalColorNew.blueElement)

            hText(text, style: .footnote)
                .foregroundColor(getTextColor)
                .padding(.leading, 9)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.vertical, 12)
        .padding(.horizontal, 16)
        .background(
            Squircle.default()
                .fill(getBackgroundColor)
                .overlay(
                    RoundedRectangle(cornerRadius: .defaultCornerRadiusNew)
                        .strokeBorder(hBorderColorNew.translucentOne, lineWidth: 0.5)
                )
        )
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, 16)
    }

    @hColorBuilder
    var getTextColor: some hColor {
        switch type {
        case .info:
            hSignalColorNew.blueText
        case .attention:
            hSignalColorNew.amberText
        case .error:
            hSignalColorNew.redText
        case .campaign:
            hSignalColorNew.greenText
        }
    }

    @hColorBuilder
    var getBackgroundColor: some hColor {
        switch type {
        case .info:
            hSignalColorNew.blueFill
        case .attention:
            hSignalColorNew.amberFill
        case .error:
            hSignalColorNew.redFill
        case .campaign:
            hSignalColorNew.greenFill
        }
    }
}

struct InfoCard_Previews: PreviewProvider {
    static var previews: some View {
        InfoCard(text: L10n.changeAddressCoverageInfoText, type: .info)
    }
}

public enum InfoCardType {
    case info
    case attention
    case error
    case campaign
}
