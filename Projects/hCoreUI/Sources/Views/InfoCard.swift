import SwiftUI
import hCore

public struct InfoCard<T>: View where T: View {
    let text: String
    let type: InfoCardType
    let buttonView: T?

    public init(
        text: String,
        type: InfoCardType,
        buttonView: T? = nil
    ) {
        self.text = text
        self.type = type
        self.buttonView = buttonView
    }

    public var body: some View {
        HStack(alignment: .top, spacing: 0) {
            Image(uiImage: hCoreUIAssets.infoIconFilled.image)
                .foregroundColor(getIconColor)

            VStack(spacing: 12) {
                hText(text, style: .footnote)
                    .foregroundColor(getTextColor)

                if let buttonView = buttonView {
                    buttonView
                }
            }
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

    @hColorBuilder
    var getIconColor: some hColor {
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
        InfoCard(
            text: L10n.changeAddressCoverageInfoText,
            type: .info,
            buttonView: EmptyView()
        )
    }
}

public enum InfoCardType {
    case info
    case attention
    case error
    case campaign
}
