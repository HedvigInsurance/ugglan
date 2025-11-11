import SwiftUI
import hCore

public struct SuccessScreen: View {
    let title: String?
    let subTitle: String?
    let formPosition: ContentPosition?

    public init(
        title: String? = nil,
        subtitle: String? = nil,
        formPosition: ContentPosition? = nil
    ) {
        self.title = title
        subTitle = subtitle
        self.formPosition = formPosition
    }

    public init(
        successViewTitle: String,
        successViewBody: String
    ) {
        title = successViewTitle
        subTitle = successViewBody
        formPosition = nil
    }

    public var body: some View {
        StateView(
            type: .success,
            title: title ?? "",
            bodyText: subTitle,
            formPosition: formPosition
        )
    }
}

#Preview("SuccessScreenWithoutButtons") {
    SuccessScreen(
        successViewTitle: "SUCCESS",
        successViewBody: "success"
    )
}

#Preview("SuccessScreenWithButtons") {
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

#Preview("SuccessScreenWithCustomBottom") {
    Localization.Locale.currentLocale.send(.en_SE)
    return SuccessScreen(title: "TITLE", subtitle: "SUBTITLE")
        .hSuccessBottomAttachedView {
            hSection {
                VStack(spacing: .padding16) {
                    InfoCard(text: L10n.TravelCertificate.downloadRecommendation, type: .info)
                    VStack(spacing: .padding8) {
                        hButton(
                            .large,
                            .primary,
                            content: .init(title: L10n.Certificates.download),
                            {}
                        )

                        hCloseButton {}
                    }
                }
            }
            .sectionContainerStyle(.transparent)
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
        environment(\.hSuccessBottomAttachedView, AnyView(content()))
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
        environment(\.hCustomSuccessView, AnyView(content()))
    }
}
