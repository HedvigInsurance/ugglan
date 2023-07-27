import SwiftUI
import hCore

public struct RetryView: View {
    var title: String
    var retryTitle: String
    var action: (() -> Void)?
    @Environment(\.hRetryBottomAttachedView) var bottomAttachedView

    public init(
        title: String,
        retryTitle: String,
        action: (() -> Void)? = nil
    ) {
        self.title = title
        self.retryTitle = retryTitle
        self.action = action
    }

    public var body: some View {
        ZStack(alignment: .bottom) {
            hSection {
                Group {
                    Image(uiImage: hCoreUIAssets.warningTriangleFilled.image)
                        .resizable()
                        .foregroundColor(hSignalColorNew.amberElement)
                        .frame(width: 24, height: 24)
                    VStack(spacing: 0) {
                        hText(L10n.somethingWentWrong)
                        hText(title, style: .body)
                            .foregroundColor(hTextColorNew.secondary)
                            .multilineTextAlignment(.center)
                    }
                    hButton.SmallButtonFilled {
                        action?()
                    } content: {
                        hText(retryTitle)
                    }
                }
                .padding(8)
            }
            .frame(maxWidth: 350, maxHeight: .infinity)
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
            title:
                "very long descrption very long descrption very long descrption very long descrption very long descrption very long descrption very long descrption very long descrption very long descrption very long descrption very long descrption very long descrption ",
            retryTitle: "Try again"
        )
        .hRetryAttachToBottom {
            hSection {
                hButton.LargeButtonPrimary {

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
