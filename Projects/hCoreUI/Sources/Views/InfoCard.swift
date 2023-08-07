import SwiftUI
import hCore

public struct InfoCard: View {
    let text: String
    let type: InfoCardType
    @Environment(\.hInfoCardButtonConfig) var buttonsConfig

    public init(
        text: String,
        type: InfoCardType
    ) {
        self.text = text
        self.type = type
    }

    public var body: some View {
        HStack(alignment: .top, spacing: 0) {
            Image(uiImage: type.image)
                .resizable()
                .foregroundColor(imageColor)
                .frame(width: 16, height: 16)
            VStack(alignment: .leading) {
                hText(text, style: .footnote)
                    .foregroundColor(getTextColor)
                    .multilineTextAlignment(.leading)
                    .padding(.leading, 9)
                if let buttonsConfig {
                    if buttonsConfig.count > 1 {
                        HStack(spacing: 8) {
                            ForEach(buttonsConfig, id: \.buttonTitle) { config in
                                hButton.MediumButtonFilled {
                                    config.buttonAction()
                                } content: {
                                    hText(config.buttonTitle, style: .standardSmall)
                                        .frame(maxWidth: .infinity)
                                }
                                .hButtonConfigurationType(.secondaryAlt)
                            }
                        }
                    } else {
                        ForEach(buttonsConfig, id: \.buttonTitle) { config in
                            hButton.MediumButtonFilled {
                                config.buttonAction()
                            } content: {
                                hText(config.buttonTitle, style: .standardSmall)
                                    .frame(maxWidth: .infinity)
                            }
                            .hButtonConfigurationType(.secondaryAlt)
                        }
                    }
                }
            }
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
    var imageColor: some hColor {
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
        VStack {
            InfoCard(text: L10n.changeAddressCoverageInfoText, type: .info)
                .buttons([
                    .init(
                        buttonTitle: "Title",
                        buttonAction: {

                        }
                    ),
                    .init(
                        buttonTitle: "Title 2",
                        buttonAction: {

                        }
                    ),
                ])

            InfoCard(text: L10n.changeAddressCoverageInfoText, type: .info)
                .buttons([
                    .init(
                        buttonTitle: "Title",
                        buttonAction: {

                        }
                    )
                ])

            InfoCard(text: L10n.changeAddressCoverageInfoText, type: .attention)

            InfoCard(text: L10n.changeAddressCoverageInfoText, type: .campaign)
            InfoCard(text: L10n.changeAddressCoverageInfoText, type: .error)
        }
    }
}

public enum InfoCardType {
    case info
    case attention
    case error
    case campaign

    var image: UIImage {
        switch self {
        case .info:
            return hCoreUIAssets.infoIconFilled.image
        case .attention:
            return hCoreUIAssets.warningTriangleFilled.image
        case .error:
            return hCoreUIAssets.warningTriangleFilled.image
        case .campaign:
            return hCoreUIAssets.campaignSmall.image

        }
    }
}

private struct EnvironmentCardButtonsConfig: EnvironmentKey {
    static let defaultValue: [InfoCardButtonConfig]? = nil
}

extension EnvironmentValues {
    public var hInfoCardButtonConfig: [InfoCardButtonConfig]? {
        get { self[EnvironmentCardButtonsConfig.self] }
        set { self[EnvironmentCardButtonsConfig.self] = newValue }
    }
}

extension InfoCard {
    public func buttons(_ configs: [InfoCardButtonConfig]) -> some View {
        self.environment(\.hInfoCardButtonConfig, configs)
    }
}

public struct InfoCardButtonConfig {
    let buttonTitle: String
    let buttonAction: () -> Void

    public init(buttonTitle: String, buttonAction: @escaping () -> Void) {
        self.buttonTitle = buttonTitle
        self.buttonAction = buttonAction
    }
}
