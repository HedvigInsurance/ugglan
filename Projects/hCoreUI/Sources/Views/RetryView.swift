import SwiftUI
import hCore

public struct RetryView: View {
    var title: String?
    var subtitle: String
    var retryTitle: String
    var action: (() -> Void)?
    @Environment(\.hRetryBottomAttachedView) var bottomAttachedView

    public init(
        title: String? = L10n.somethingWentWrong,
        subtitle: String,
        retryTitle: String = L10n.generalRetry,
        action: (() -> Void)? = nil
    ) {
        self.title = title
        self.subtitle = subtitle
        self.retryTitle = retryTitle
        self.action = action
    }

    public var body: some View {
        ZStack(alignment: .bottom) {
            VStack {
                Spacer()
                Spacer()
                hSection {
                    Group {
                        Image(uiImage: hCoreUIAssets.warningTriangleFilled.image)
                            .resizable()
                            .foregroundColor(hSignalColor.amberElement)
                            .frame(width: 24, height: 24)
                        VStack(spacing: 0) {
                            if let title {
                                hText(title)
                                    .foregroundColor(hTextColor.primaryTranslucent)
                            }
                            hText(subtitle, style: .body)
                                .foregroundColor(hTextColor.secondaryTranslucent)
                                .multilineTextAlignment(.center)
                        }
                        if let action {
                            hButton.SmallButton(type: .primary) {
                                action()
                            } content: {
                                hText(retryTitle)
                            }
                        }
                    }
                    .padding(8)
                }
                .frame(maxWidth: 350)
                Spacer()
                Spacer()
                Spacer()
            }
            bottomAttachedView
        }
        .frame(maxHeight: .infinity)
        .sectionContainerStyle(.transparent)
    }
}

struct RetryView_Previews: PreviewProvider {
    static var previews: some View {
        Localization.Locale.currentLocale = .en_SE
        return RetryView(
            subtitle:
                "very long descrption very long descrption very long descrption very long descrption very long descrption very long descrption very long descrption very long descrption very long descrption very long descrption very long descrption very long descrption ",
            retryTitle: "Try again"
        )
        .hRetryAttachToBottom {
            hSection {
                hButton.LargeButton(type: .primary) {
                } content: {
                    hText("Test button")
                }

            }
        }
    }
}

private struct EnvironmentHRetryBottomAttachedView: EnvironmentKey {
    static let defaultValue: AnyView? = nil
}

extension EnvironmentValues {
    public var hRetryBottomAttachedView: AnyView? {
        get { self[EnvironmentHRetryBottomAttachedView.self] }
        set { self[EnvironmentHRetryBottomAttachedView.self] = newValue }
    }
}

extension RetryView {
    public func hRetryAttachToBottom<Content: View>(@ViewBuilder _ content: () -> Content) -> some View {
        self.environment(\.hRetryBottomAttachedView, AnyView(content()))
    }
}
