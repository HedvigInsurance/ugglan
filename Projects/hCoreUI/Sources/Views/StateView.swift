import SwiftUI
import hCore

struct StateView: View {
    let type: StateType
    let title: String
    let bodyText: String?
    private let formPosition: ContentPosition?
    private let attachContentToBottom: Bool
    @Environment(\.hStateViewButtonConfig) var buttonConfig
    @Environment(\.hSuccessBottomAttachedView) var bottomAttachedView
    @Environment(\.hExtraTopPadding) var extraTopPadding

    init(
        type: StateType,
        title: String,
        bodyText: String?,
        formPosition: ContentPosition? = nil,
        attachContentToBottom: Bool = false
    ) {
        self.type = type
        self.title = title
        self.bodyText = bodyText
        self.formPosition = formPosition
        self.attachContentToBottom = attachContentToBottom
    }

    var body: some View {
        if let formPosition {
            hForm {
                if !attachContentToBottom {
                    centralContent
                        .padding(.bottom, .padding32)
                        .padding(.top, extraTopPadding ? 32 : 0)
                }
            }
            .hFormContentPosition(formPosition)
            .hFormAttachToBottom {
                bottomButtonsView
                    .padding(.vertical, .padding16)
            }
        } else {
            if buttonConfig != nil {
                ZStack(alignment: .bottom) {
                    BackgroundView().ignoresSafeArea()
                    VStack {
                        Spacer()
                        centralContent
                        Spacer()
                    }
                    bottomButtonsView
                }
            } else {
                ZStack(alignment: .bottom) {
                    VStack {
                        Spacer()
                        centralContent
                        Spacer()
                    }
                    if let bottomAttachedView = bottomAttachedView {
                        bottomAttachedView
                    }
                }
            }
        }
    }

    private var centralContent: some View {
        hSection {
            VStack(spacing: 16) {
                if let image = type.image {
                    Image(uiImage: image)
                        .resizable()
                        .frame(width: 40, height: 40)
                        .foregroundColor(type.imageColor)
                        .accessibilityHidden(true)
                }

                VStack(spacing: 0) {
                    hText(title)
                        .foregroundColor(hTextColor.Opaque.primary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, .padding32)
                    if let bodyText {
                        hText(bodyText)
                            .foregroundColor(hTextColor.Translucent.secondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, .padding32)
                    }
                }
                .accessibilityElement(children: .combine)

                if let button = buttonConfig?.actionButton {
                    hButton.MediumButton(type: .primary) {
                        button.buttonAction()
                    } content: {
                        hText(button.buttonTitle ?? type.buttonText)
                    }
                }
            }
        }
        .sectionContainerStyle(.transparent)
    }

    private var bottomButtonsView: some View {
        hSection {
            VStack(spacing: 8) {
                if attachContentToBottom {
                    centralContent
                        .padding(.bottom, .padding40)
                        .padding(.top, extraTopPadding ? 32 : 0)
                }
                if let actionButton = buttonConfig?.actionButtonAttachedToBottom {
                    hButton.LargeButton(type: .primary) {
                        actionButton.buttonAction()
                    } content: {
                        hText(actionButton.buttonTitle ?? "")
                    }
                }
                if let dismissButton = buttonConfig?.dismissButton {
                    hButton.LargeButton(type: .ghost) {
                        dismissButton.buttonAction()
                    } content: {
                        hText(dismissButton.buttonTitle ?? L10n.openChat, style: .body1)
                    }
                }
            }
        }
        .sectionContainerStyle(.transparent)
    }
}

@MainActor
enum StateType {
    case error
    case information
    case success
    case bankId
    case empty

    var image: UIImage? {
        switch self {
        case .error:
            return hCoreUIAssets.warningTriangleFilled.image
        case .information:
            return hCoreUIAssets.infoFilled.image
        case .success:
            return hCoreUIAssets.checkmarkFilled.image
        case .bankId:
            return hCoreUIAssets.bankID.image
        case .empty:
            return nil
        }
    }

    @hColorBuilder
    var imageColor: some hColor {
        switch self {
        case .error:
            hSignalColor.Amber.element
        case .information:
            hSignalColor.Blue.element
        case .success:
            hSignalColor.Green.element
        default:
            hSignalColor.Amber.element
        }
    }

    var buttonText: String {
        switch self {
        case .error:
            return L10n.generalRetry
        case .information:
            return L10n.generalConfirm
        default:
            return L10n.generalContinueButton
        }
    }
}

public struct StateButton {
    fileprivate let buttonTitle: String?
    fileprivate let buttonAction: () -> Void

    public init(
        buttonTitle: String? = nil,
        buttonAction: @escaping () -> Void
    ) {
        self.buttonTitle = buttonTitle
        self.buttonAction = buttonAction
    }
}

public struct StateViewButtonConfig {
    let actionButton: StateViewButton?
    let actionButtonAttachedToBottom: StateViewButton?
    let dismissButton: StateViewButton?

    public init(
        actionButton: StateViewButton? = nil,
        actionButtonAttachedToBottom: StateViewButton? = nil,
        dismissButton: StateViewButton? = nil
    ) {
        self.actionButton = actionButton
        self.actionButtonAttachedToBottom = actionButtonAttachedToBottom
        self.dismissButton = dismissButton
    }

    public struct StateViewButton {
        let buttonTitle: String?
        let buttonAction: () -> Void

        public init(buttonTitle: String? = nil, buttonAction: @escaping () -> Void) {
            self.buttonTitle = buttonTitle
            self.buttonAction = buttonAction
        }
    }
}

@MainActor
private struct StateViewButtonConfigKey: @preconcurrency EnvironmentKey {
    static let defaultValue: StateViewButtonConfig? = nil
}

extension EnvironmentValues {
    public var hStateViewButtonConfig: StateViewButtonConfig? {
        get { self[StateViewButtonConfigKey.self] }
        set { self[StateViewButtonConfigKey.self] = newValue }
    }
}

extension View {
    public func hStateViewButtonConfig(_ stateViewButtonConfigKey: StateViewButtonConfig?) -> some View {
        self.environment(\.hStateViewButtonConfig, stateViewButtonConfigKey)
    }
}

#Preview {
    StateView(
        type: .error,
        title: "title",
        bodyText: "body"
    )
    .hStateViewButtonConfig(
        .init(
            actionButton: .init(buttonAction: {}),
            actionButtonAttachedToBottom: nil,
            dismissButton: nil
        )
    )
}
