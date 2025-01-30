import SwiftUI
import hCore

public struct SuccessScreen: View {
    let title: String?
    let subTitle: String?

    public init(
        title: String? = nil,
        subtitle: String? = nil
    ) {
        self.title = title
        self.subTitle = subtitle
    }

    public init(
        successViewTitle: String,
        successViewBody: String
    ) {
        self.title = successViewTitle
        self.subTitle = successViewBody
    }

    public var body: some View {
        StateView(
            type: .success,
            title: title ?? "",
            bodyText: subTitle
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
            successViewBody: "success"
        )
        .hStateViewButtonConfig(
            .init(
                actionButton: .init(buttonTitle: nil, buttonAction: {}),
                actionButtonAttachedToBottom:
                    .init(
                        buttonTitle: "Extra button",
                        buttonAction: {}
                    ),
                dismissButton:
                    .init(
                        buttonTitle: "Close",
                        buttonAction: {}
                    )
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

@MainActor
private struct EnvironmentHSuccessBottomAttachedView: @preconcurrency EnvironmentKey {
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

@MainActor
private struct EnvironmentHCustomSuccessView: @preconcurrency EnvironmentKey {
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
