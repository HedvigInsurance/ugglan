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
            Image(uiImage: hCoreUIAssets.infoSmall.image)
                .foregroundColor(hSignalColorNew.blueElement)

            hTextNew(text, style: .footnote)
                .foregroundColor(getTextColor)
                .padding(.leading, 9)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding([.top, .bottom], 12)
        .padding([.leading, .trailing], 16)
        .background(
            Squircle.default()
                .fill(getBackgroundColor)
                .overlay(
                    RoundedRectangle(cornerRadius: .defaultCornerRadiusNew)
                        .strokeBorder(getBorderColor, lineWidth: 0.5)
                )
        )
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding([.leading, .trailing], 16)
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

    @hColorBuilder
    var getBorderColor: some hColor {
        switch type {
        case .info:
            hSignalColorNew.blueElement
        case .attention:
            hSignalColorNew.amberElement
        case .error:
            hSignalColorNew.redElement
        case .campaign:
            hSignalColorNew.greenElement
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
