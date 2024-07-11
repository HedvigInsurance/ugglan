import SwiftUI
import hCore

public struct InfoCard: View {
    let text: String
    let type: NotificationType
    @Environment(\.hInfoCardButtonConfig) var buttonsConfig
    @Environment(\.hInfoCardCustomView) var customContentView

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
            }
            if let customContentView = customContentView {
                customContentView
                    .padding(.leading, .padding8)
                    .hUseLightMode
            } else {
                VStack(alignment: .leading) {
                    hText(text, style: .footnote)
                        .foregroundColor(type.textColor)
                        .multilineTextAlignment(.leading)
                    if let buttonsConfig {
                        if buttonsConfig.count > 1 {
                            HStack(spacing: 4) {
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
                .padding(.leading, .padding8)
                .hUseLightMode
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.vertical, .padding12)
        .padding(.horizontal, .padding16)
        .modifier(NotificationStyle(type: type))
        .fixedSize(horizontal: false, vertical: true)
    }
    //<<<<<<< HEAD
    //
    //    @hColorBuilder
    //    var getTextColor: some hColor {
    //        switch type {
    //        case .info:
    //            hSignalColor.Blue.text
    //        case .attention:
    //            hSignalColor.Amber.text
    //        case .error:
    //            hSignalColor.Red.text
    //        case .campaign:
    //            hSignalColor.Green.text
    //        case .disabled:
    //            hTextColor.Opaque.accordion
    //        }
    //    }
    //
    //    @hColorBuilder
    //    var imageColor: some hColor {
    //        switch type {
    //        case .info:
    //            hSignalColor.Blue.element
    //        case .attention:
    //            hSignalColor.Amber.element
    //        case .error:
    //            hSignalColor.Red.element
    //        case .campaign:
    //            hSignalColor.Green.element
    //        case .disabled:
    //            hFillColor.Opaque.secondary
    //        }
    //    }
    //=======
    //>>>>>>> main
}

struct InfoCard_Previews: PreviewProvider {
    static var previews: some View {
        hSection {
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
}

public enum InfoCardType {
    case info
    case attention
    case error
    case campaign
    case disabled

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

public enum InfoCardLayoutStyle {
    case defaultStyle
    case bannerStyle
}

//struct InfoCardStyle: ViewModifier {
//    let type: InfoCardType
//    @Environment(\.hInfoCardLayoutStyle) var layoutStyle
//    func body(content: Content) -> some View {
//        switch layoutStyle {
//        case .rectange:
//            content
//                .background(
//                    Rectangle()
//                        .fill(getBackgroundColor)
//                        .overlay(
//                            Rectangle()
//                                .strokeBorder(hBorderColor.primary, lineWidth: 0.5)
//                        )
//                )
//        case .roundedRectangle:
//            content
//                .background(
//                    Squircle.default()
//                        .fill(getBackgroundColor)
//                        .overlay(
//                            RoundedRectangle(cornerRadius: .cornerRadiusL)
//                                .strokeBorder(hBorderColor.primary, lineWidth: 0.5)
//                        )
//                )
//        }
//    }
//
//    @hColorBuilder
//    var getBackgroundColor: some hColor {
//        switch type {
//        case .info:
//            hSignalColor.Blue.fill
//        case .attention:
//            hSignalColor.Amber.fill
//        case .error:
//            hSignalColor.Red.fill
//        case .campaign:
//            hSignalColor.Green.fill
//        case .disabled:
//            hSurfaceColor.Opaque.primary
//        }
//    }
//}
