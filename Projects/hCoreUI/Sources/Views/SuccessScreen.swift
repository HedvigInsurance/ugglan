import PresentableStore
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
                    content
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
            ZStack(alignment: .bottom) {
                VStack {
                    Spacer()
                    content
                    Spacer()
                }
                if let successBottomView = successBottomView {
                    successBottomView
                }
            }
        }
    }

    private var content: some View {
        StateView(
            type: .success,
            title: title ?? "",
            bodyText: subTitle,
            button: (bottomAttachedButtons?.actionButton != nil)
                ? .init(
                    buttonTitle: bottomAttachedButtons?.actionButton?.buttonTitle,
                    buttonAction: bottomAttachedButtons?.actionButton?.buttonAction ?? {}
                ) : nil
        )
    }
}

public struct SuccessScreenButtonConfig {
    fileprivate let actionButton: SuccessScreenButton?
    fileprivate let primaryButton: SuccessScreenButton?
    fileprivate let ghostButton: SuccessScreenButton?

    public init(
        actionButton: SuccessScreenButton?,
        primaryButton: SuccessScreenButton? = nil,
        ghostButton: SuccessScreenButton? = nil
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
                actionButton: .init(buttonAction: {}),
                primaryButton: .init(buttonTitle: "title", buttonAction: {}),
                ghostButton: .init(buttonTitle: "title2", buttonAction: {})
            )
        )
    }
}

struct SuccessScreenWithCustomBottom_Previews: PreviewProvider {
    static var previews: some View {
        Localization.Locale.currentLocale.send(.en_SE)
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

private struct EnvironmentHCustomSuccessView: EnvironmentKey {
    static let defaultValue: AnyView? = nil
}

extension EnvironmentValues {
    public var hCustomSuccessView: AnyView? {
        get { self[EnvironmentHCustomSuccessView.self] }
        set { self[EnvironmentHCustomSuccessView.self] = newValue }
    }
}

extension View {
    public func hCustomSuccessView<Content: View>(@ViewBuilder _ content: () -> Content) -> some View {
        self.environment(\.hCustomSuccessView, AnyView(content()))
    }
}
