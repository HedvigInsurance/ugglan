import Presentation
import SwiftUI
import hCore

public enum SuccessScreenIcon {
    case tick
    case circularTick
}

public struct SuccessScreen: View {
    let title: String?
    let subTitle: String?
    let withButtons: Bool
    let buttons: SuccessScreenButtonConfig?
    let icon: SuccessScreenIcon
    @Environment(\.hSuccessBottomAttachedView) var successBottomView

    public init(
        title: String? = nil,
        subtitle: String? = nil,
        icon: SuccessScreenIcon? = nil
    ) {
        self.title = title
        self.withButtons = false
        self.subTitle = subtitle
        self.buttons = nil
        self.icon = icon ?? .tick
    }

    public init(
        successViewTitle: String,
        successViewBody: String,
        buttons: SuccessScreenButtonConfig? = nil,
        icon: SuccessScreenIcon? = nil
    ) {
        self.title = successViewTitle
        self.subTitle = successViewBody
        self.buttons = buttons
        self.withButtons = buttons != nil
        self.icon = icon ?? .tick
    }

    public var body: some View {
        if withButtons {
            ZStack(alignment: .bottom) {
                BackgroundView().ignoresSafeArea()
                VStack {
                    Spacer()
                    Spacer()
                    centralContent
                    Spacer()
                    Spacer()
                    Spacer()
                }
                hSection {
                    VStack(spacing: 8) {
                        if let primaryButton = buttons?.primaryButton {
                            hButton.LargeButton(type: .primary) {
                                primaryButton.buttonAction()
                            } content: {
                                hText(primaryButton.buttonTitle ?? L10n.generalDoneButton)
                            }
                        }
                        if let ghostButton = buttons?.ghostButton {
                            hButton.LargeButton(type: .ghost) {
                                ghostButton.buttonAction()
                            } content: {
                                hText(ghostButton.buttonTitle ?? L10n.generalCloseButton)
                            }
                        }
                    }
                }
                .sectionContainerStyle(.transparent)
            }
        } else {
            VStack(spacing: 20) {
                Spacer()
                centralContent
                Spacer()
                if let successBottomView = successBottomView {
                    successBottomView
                }
            }
        }
    }

    private var centralContent: some View {
        VStack(spacing: 16) {
            Image(
                uiImage: icon == .tick
                    ? hCoreUIAssets.checkmark.image : hCoreUIAssets.checkmarkFilled.image
            )
            .resizable()
            .frame(width: icon == .tick ? 24 : 40, height: icon == .tick ? 24 : 40)
            .foregroundColor(hSignalColor.Green.element)
            hSection {
                VStack(spacing: 0) {
                    if let title {
                        hText(title)
                    }
                    hText(subTitle ?? "")
                        .foregroundColor(hTextColor.Opaque.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, .padding32)
                }
            }
            .sectionContainerStyle(.transparent)
        }
    }
}

public struct SuccessScreenButtonConfig {
    fileprivate let primaryButton: SuccessScreenButton?
    fileprivate let ghostButton: SuccessScreenButton?

    public init(
        primaryButton: SuccessScreenButton? = nil,
        ghostButton: SuccessScreenButton? = nil
    ) {
        self.primaryButton = primaryButton
        self.ghostButton = ghostButton
    }

    public struct SuccessScreenButton {
        fileprivate let buttonTitle: String?
        fileprivate let buttonAction: () -> Void

        public init(buttonTitle: String? = nil, buttonAction: @escaping () -> Void) {
            self.buttonTitle = buttonTitle
            self.buttonAction = buttonAction
        }
    }
}

struct SuccessScreen_Previews: PreviewProvider {
    static var previews: some View {
        SuccessScreen(
            successViewTitle: "SUCCESS",
            successViewBody: "success",
            buttons: SuccessScreenButtonConfig(
                primaryButton: .init(buttonTitle: "title", buttonAction: {}),
                ghostButton: .init(buttonTitle: "title2", buttonAction: {})
            )
        )
    }
}

struct SuccessScreenWithCustomBottom_Previews: PreviewProvider {
    static var previews: some View {
        Localization.Locale.currentLocale = .en_SE
        return SuccessScreen(title: "TITLE", subtitle: "SUBTITLE")
            .hSuccessBottomAttachedView {
                hSection {
                    VStack(spacing: 16) {
                        InfoCard(text: L10n.TravelCertificate.downloadRecommendation, type: .info)
                        VStack(spacing: 8) {
                            hButton.LargeButton(type: .primary) {

                            } content: {
                                hText(L10n.TravelCertificate.download)
                            }
                            hButton.LargeButton(type: .ghost) {

                            } content: {
                                hText(L10n.generalCloseButton)
                            }
                        }
                    }
                }
                .sectionContainerStyle(.transparent)
            }
    }
}

private struct EnvironmentHSuccessBottomAttachedView: EnvironmentKey {
    static let defaultValue: AnyView? = nil
}

extension EnvironmentValues {
    public var hSuccessBottomAttachedView: AnyView? {
        get { self[EnvironmentHSuccessBottomAttachedView.self] }
        set { self[EnvironmentHSuccessBottomAttachedView.self] = newValue }
    }
}

extension View {
    public func hSuccessBottomAttachedView<Content: View>(@ViewBuilder _ content: () -> Content) -> some View {
        self.environment(\.hSuccessBottomAttachedView, AnyView(content()))
    }
}
