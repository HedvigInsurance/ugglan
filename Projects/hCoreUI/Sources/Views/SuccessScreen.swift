import Presentation
import SwiftUI
import hCore

public enum SuccessScreenIcon {
    case tick
    case circularTick
}

public struct SuccessScreen: View {
    let title: String
    let subTitle: String?
    let withButtons: Bool
    let successViewButtonAction: (() -> Void)?
    @Environment(\.hUsePrimaryButton) var usePrimaryButton
    let icon: SuccessScreenIcon

    public init(
        title: String,
        icon: SuccessScreenIcon? = nil
    ) {
        self.title = title
        self.withButtons = false
        self.subTitle = nil
        self.successViewButtonAction = nil
        self.icon = icon ?? .tick
    }

    public init(
        successViewTitle: String,
        successViewBody: String,
        successViewButtonAction: @escaping () -> Void,
        icon: SuccessScreenIcon? = nil
    ) {
        self.withButtons = true
        self.title = successViewTitle
        self.subTitle = successViewBody
        self.successViewButtonAction = successViewButtonAction
        self.icon = icon ?? .tick
    }

    public var body: some View {
        if withButtons {
            ZStack(alignment: .bottom) {
                BackgroundView().ignoresSafeArea()
                VStack {
                    Spacer()
                    Spacer()
                    VStack(spacing: 16) {
                        Image(
                            uiImage: icon == .tick
                                ? hCoreUIAssets.tick.image : hCoreUIAssets.circularCheckmarkFilled.image
                        )
                        .resizable()
                        .frame(width: icon == .tick ? 24 : 40, height: icon == .tick ? 24 : 40)
                        .foregroundColor(hSignalColor.greenElement)
                        hSection {
                            VStack(spacing: 0) {
                                hText(title)
                                hText(subTitle ?? "")
                                    .foregroundColor(hTextColor.secondary)
                                    .multilineTextAlignment(.center)
                                    .padding(.horizontal, 32)
                            }
                        }
                        .sectionContainerStyle(.transparent)
                    }
                    Spacer()
                    Spacer()
                    Spacer()
                }
                hSection {
                    ZStack {
                        if usePrimaryButton {
                            hButton.LargeButton(type: .primary) {
                                successViewButtonAction?()
                            } content: {
                                hText(L10n.generalDoneButton)
                            }

                        } else {
                            hButton.LargeButton(type: .ghost) {
                                successViewButtonAction?()
                            } content: {
                                hText(L10n.generalCloseButton)
                            }
                        }
                    }
                }
                .sectionContainerStyle(.transparent)
            }
        } else {
            hSection {
                VStack(spacing: 20) {
                    Spacer()
                    Image(uiImage: hCoreUIAssets.tick.image)
                        .resizable()
                        .foregroundColor(hSignalColor.greenElement)
                        .frame(width: 24, height: 24)
                    hText(title)
                    Spacer()
                }
            }
            .sectionContainerStyle(.transparent)
        }
    }
}

struct SuccessScreen_Previews: PreviewProvider {
    static var previews: some View {
        SuccessScreen(title: "SUCCESS")
    }
}

extension SuccessScreen {
    public static func journey(with title: String) -> some JourneyPresentation {
        HostingJourney(
            rootView: SuccessScreen(title: title),
            options: [.prefersNavigationBarHidden(true)]
        )
        .hidesBackButton
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

private struct EnvironmentHUsePrimaryButton: EnvironmentKey {
    static let defaultValue: Bool = false
}

extension EnvironmentValues {
    public var hUsePrimaryButton: Bool {
        get { self[EnvironmentHUsePrimaryButton.self] }
        set { self[EnvironmentHUsePrimaryButton.self] = newValue }
    }
}

extension View {
    public var hUsePrimaryButton: some View {
        self.environment(\.hUsePrimaryButton, true)
    }
}
