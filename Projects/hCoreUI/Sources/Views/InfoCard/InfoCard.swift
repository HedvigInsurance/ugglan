import SwiftUI
import hCore

public struct InfoCard: View {
    let text: String
    let type: NotificationType
    @Environment(\.hInfoCardButtonConfig) var buttonsConfig
    @Environment(\.hInfoCardCustomView) var customContentView
    @Environment(\.sizeCategory) var sizeCategory

    public init(
        text: String,
        type: NotificationType
    ) {
        self.text = text
        self.type = type
    }

    public var body: some View {
        HStack(alignment: .top, spacing: 0) {
            VStack(spacing: .padding8) {
                Image(uiImage: type.image)
                    .resizable()
                    .foregroundColor(type.imageColor)
                    .frame(width: 20, height: 20)
                    .accessibilityValue(type.displayName)
            }
            if let customContentView = customContentView {
                customContentView
                    .padding(.leading, .padding8)
                    .hUseLightMode
            } else {
                switch type {
                case .neutral:
                    buttonsView
                default:
                    buttonsView
                        .hUseLightMode
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.vertical, .padding12)
        .padding(.horizontal, .padding16)
        .modifier(NotificationStyle(type: type))
        .fixedSize(horizontal: false, vertical: true)
        .accessibilityElement(children: .combine)
        .hButtonTakeFullWidth(true)
    }

    private var buttonsView: some View {
        VStack(alignment: .leading) {
            hText(text, style: .label)
                .foregroundColor(type.textColor)
                .multilineTextAlignment(.leading)
                .padding(.bottom, .padding4)
            if let buttonsConfig {
                if buttonsConfig.count > 1 {
                    HStack(spacing: 4) {
                        ForEach(buttonsConfig, id: \.buttonTitle) { config in
                            if type == .neutral {
                                hButton.SmallButton(type: .secondary) {
                                    config.buttonAction()
                                } content: {
                                    hText(config.buttonTitle, style: .label)
                                }
                            } else {
                                hButton.SmallButton(type: .secondaryAlt) {
                                    config.buttonAction()
                                } content: {
                                    hText(config.buttonTitle, style: .label)
                                }
                                .hUseLightMode
                            }
                        }
                    }
                } else {
                    ForEach(buttonsConfig, id: \.buttonTitle) { config in
                        if type == .neutral {
                            hButton.SmallButton(type: .secondary) {
                                config.buttonAction()
                            } content: {
                                hText(config.buttonTitle, style: .label)
                            }
                        } else {
                            hButton.SmallButton(type: .secondaryAlt) {
                                config.buttonAction()
                            } content: {
                                hText(config.buttonTitle, style: .label)
                            }
                            .hUseLightMode
                        }
                    }
                }
            }
        }
        .padding(.leading, .padding8)
    }
}

struct InfoCard_Previews: PreviewProvider {
    static var previews: some View {
        hSection {
            VStack {
                InfoCard(text: L10n.changeAddressCoverageInfoText(30), type: .info)
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

                InfoCard(text: L10n.changeAddressCoverageInfoText(30), type: .info)
                    .buttons([
                        .init(
                            buttonTitle: "Title",
                            buttonAction: {

                            }
                        )
                    ])

                InfoCard(text: L10n.changeAddressCoverageInfoText(30), type: .attention)

                InfoCard(text: L10n.changeAddressCoverageInfoText(30), type: .campaign)
                InfoCard(text: L10n.changeAddressCoverageInfoText(30), type: .error)
                InfoCard(text: "", type: .error)
                    .hInfoCardCustomView {
                        Text("Testing custom texzt view")

                    }

                InfoCard(text: L10n.changeAddressCoverageInfoText(30), type: .neutral)
                    .buttons([
                        .init(
                            buttonTitle: "Title",
                            buttonAction: {

                            }
                        )
                    ])
            }
        }
    }
}

public enum InfoCardType {
    case info
    case attention
    case error
    case campaign
    case disabled

    @MainActor
    var image: UIImage {
        switch self {
        case .info:
            return hCoreUIAssets.infoFilled.image
        case .attention:
            return hCoreUIAssets.warningTriangleFilled.image
        case .error:
            return hCoreUIAssets.warningTriangleFilled.image
        case .campaign:
            return hCoreUIAssets.campaignSmall.image
        case .disabled:
            return hCoreUIAssets.infoFilled.image
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

public struct InfoCardButtonConfig: Sendable {
    let buttonTitle: String
    let buttonAction: @MainActor @Sendable () -> Void

    public init(buttonTitle: String, buttonAction: @MainActor @Sendable @escaping () -> Void) {
        self.buttonTitle = buttonTitle
        self.buttonAction = buttonAction
    }
}

@MainActor
private struct EnvironmentInfoCardCustomView: @preconcurrency EnvironmentKey {
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
    static let defaultValue: InfoCardLayoutStyle = .defaultStyle
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

public enum InfoCardLayoutStyle: Sendable {
    case defaultStyle
    case bannerStyle
}
