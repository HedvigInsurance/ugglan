import SwiftUI
import hCore

public struct InfoCard: View {
    let text: String
    let type: InfoCardType
    @Environment(\.hInfoCardButtonConfig) var buttonsConfig
    @Environment(\.hInfoCardCustomView) var customContentView

    public init(
        text: String,
        type: InfoCardType
    ) {
        self.text = text
        self.type = type
    }

    public var body: some View {
        HStack(alignment: .top, spacing: 0) {
            VStack(spacing: 0) {
                Rectangle().fill(Color.clear)
                    .frame(width: 0, height: 2)
                Image(uiImage: type.image)
                    .resizable()
                    .foregroundColor(imageColor)
                    .frame(width: 16, height: 16)
            }
            if let customContentView = customContentView {
                customContentView
                    .padding(.leading, 8)
                    .hUseLightMode
            } else {
                VStack(alignment: .leading) {
                    hText(text, style: .footnote)
                        .foregroundColor(getTextColor)
                        .multilineTextAlignment(.leading)
                    if let buttonsConfig {
                        if buttonsConfig.count > 1 {
                            HStack(spacing: 8) {
                                ForEach(buttonsConfig, id: \.buttonTitle) { config in
                                    hButton.SmallButton(type: .secondaryAlt) {
                                        config.buttonAction()
                                    } content: {
                                        hText(config.buttonTitle, style: .standardSmall)
                                            .frame(maxWidth: .infinity)
                                    }
                                }
                            }
                        } else {
                            ForEach(buttonsConfig, id: \.buttonTitle) { config in
                                hButton.SmallButton(type: .secondaryAlt) {
                                    config.buttonAction()
                                } content: {
                                    hText(config.buttonTitle, style: .standardSmall)
                                        .frame(maxWidth: .infinity)
                                }
                            }
                        }
                    }
                }
                .padding(.leading, 8)
                .hUseLightMode
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.top, 14)
        .padding(.bottom, 16)
        .padding(.leading, 12)
        .padding(.trailing, 16)
        .modifier(InfoCardStyle(type: type))
        .fixedSize(horizontal: false, vertical: true)
    }

    @hColorBuilder
    var getTextColor: some hColor {
        switch type {
        case .info:
            hSignalColor.blueText
        case .attention:
            hSignalColor.amberText
        case .error:
            hSignalColor.redText
        case .campaign:
            hSignalColor.greenText
        }
    }

    @hColorBuilder
    var imageColor: some hColor {
        switch type {
        case .info:
            hSignalColor.blueElement
        case .attention:
            hSignalColor.amberElement
        case .error:
            hSignalColor.redElement
        case .campaign:
            hSignalColor.greenElement
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

            InfoCard(text: "", type: .error)
                .hInfoCardCustomView {
                    Text("Testing custom texzt view")

                }
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

private struct EnvironmentInfoCardCustomView: EnvironmentKey {
    static let defaultValue: AnyView? = nil
}

extension EnvironmentValues {
    public var hInfoCardCustomView: AnyView? {
        get { self[EnvironmentInfoCardCustomView.self] }
        set { self[EnvironmentInfoCardCustomView.self] = newValue }
    }
}

extension View {
    public func hInfoCardCustomView<Content: View>(@ViewBuilder _ content: () -> Content) -> some View {
        self.environment(\.hInfoCardCustomView, AnyView(content()))
    }
}

private struct EnvironmentInfoCardLayoutStyle: EnvironmentKey {
    static let defaultValue: InfoCardLayoutStyle = .roundedRectangle
}

extension EnvironmentValues {
    public var hInfoCardLayoutStyle: InfoCardLayoutStyle {
        get { self[EnvironmentInfoCardLayoutStyle.self] }
        set { self[EnvironmentInfoCardLayoutStyle.self] = newValue }
    }
}

extension View {
    public func hInfoCardLayoutStyle(_ style: InfoCardLayoutStyle) -> some View {
        self.environment(\.hInfoCardLayoutStyle, style)
    }
}

public enum InfoCardLayoutStyle {
    case roundedRectangle
    case rectange
}

struct InfoCardStyle: ViewModifier {
    let type: InfoCardType
    @Environment(\.hInfoCardLayoutStyle) var layoutStyle
    func body(content: Content) -> some View {
        switch layoutStyle {
        case .rectange:
            content
                .background(
                    Rectangle()
                        .fill(getBackgroundColor)
                        .overlay(
                            Rectangle()
                                .strokeBorder(hBorderColor.translucentOne, lineWidth: 0.5)
                        )
                )
        case .roundedRectangle:
            content
                .background(
                    Squircle.default()
                        .fill(getBackgroundColor)
                        .overlay(
                            RoundedRectangle(cornerRadius: .defaultCornerRadiusNew)
                                .strokeBorder(hBorderColor.translucentOne, lineWidth: 0.5)
                        )
                )
        }
    }

    @hColorBuilder
    var getBackgroundColor: some hColor {
        switch type {
        case .info:
            hSignalColor.blueFill
        case .attention:
            hSignalColor.amberFill
        case .error:
            hSignalColor.redFill
        case .campaign:
            hSignalColor.greenFill
        }
    }
}
