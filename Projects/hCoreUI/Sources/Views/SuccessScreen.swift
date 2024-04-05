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
    let buttons: SuccessScreenButtonConfig?
    let icon: SuccessScreenIcon

    public init(
        title: String,
        icon: SuccessScreenIcon? = nil
    ) {
        self.title = title
        self.withButtons = false
        self.subTitle = nil
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
        SuccessScreen(successViewTitle: "SUCCESS", successViewBody: "success")
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
