import Presentation
import SwiftUI
import hCore

public struct SuccessScreen: View {
    let title: String?
    let subTitle: String?
    let withButtons: Bool
    let bottomAttachedButtons: SuccessScreenButtonConfig?

    @Environment(\.hSuccessBottomAttachedView) var successBottomView

    public init(
        title: String? = nil,
        subtitle: String? = nil
    ) {
        self.title = title
        self.withButtons = false
        self.subTitle = subtitle
        self.bottomAttachedButtons = nil
    }

    public init(
        successViewTitle: String,
        successViewBody: String,
        buttons: SuccessScreenButtonConfig? = nil
    ) {
        self.title = successViewTitle
        self.subTitle = successViewBody
        self.bottomAttachedButtons = buttons
        self.withButtons = buttons != nil
    }

    public var body: some View {
        if withButtons {
            ZStack(alignment: .bottom) {
                BackgroundView().ignoresSafeArea()
                VStack {
                    Spacer()
                    StateView(
                        type: .success,
                        title: title ?? "",
                        bodyText: subTitle,
                        withButton: bottomAttachedButtons?.actionButton ?? false
                    )
                    Spacer()
                }
                hSection {
                    VStack(spacing: 8) {
                        if let primaryButton = bottomAttachedButtons?.primaryButton {
                            hButton.LargeButton(type: .primary) {
                                primaryButton.buttonAction()
                            } content: {
                                hText(primaryButton.buttonTitle ?? L10n.generalDoneButton)
                            }
                        }
                        if let ghostButton = bottomAttachedButtons?.ghostButton {
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
            StateView(
                type: .success,
                title: title ?? "",
                bodyText: subTitle,
                withButton: bottomAttachedButtons?.actionButton ?? false
            )
            if let successBottomView = successBottomView {
                successBottomView
            }
        }
    }
}

public struct SuccessScreenButtonConfig {
    fileprivate let primaryButton: SuccessScreenButton?
    fileprivate let ghostButton: SuccessScreenButton?
    fileprivate let actionButton: Bool

    public init(
        primaryButton: SuccessScreenButton? = nil,
        ghostButton: SuccessScreenButton? = nil,
        actionButton: Bool
    ) {
        self.primaryButton = primaryButton
        self.ghostButton = ghostButton
        self.actionButton = actionButton
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
                ghostButton: .init(buttonTitle: "title2", buttonAction: {}),
                actionButton: false
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
