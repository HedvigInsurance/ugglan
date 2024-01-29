import SwiftUI
import hCore

public struct GenericErrorView: View {
    private let title: String?
    private let description: String?
    private let useForm: Bool
    private let icon: ErrorIconType
    private let buttons: ErrorViewButtonConfig
    @Environment(\.hWithoutTitle) var withoutTitle
    @Environment(\.hExtraBottomPadding) var extraBottomPadding

    public init(
        title: String? = nil,
        description: String? = L10n.General.errorBody,
        useForm: Bool = true,
        icon: ErrorIconType = .triangle,
        buttons: ErrorViewButtonConfig
    ) {
        self.title = title
        self.description = description
        self.useForm = useForm
        self.icon = icon
        self.buttons = buttons
    }

    public var body: some View {
        if useForm {
            hForm {
                content
                    .padding(.bottom, 32)
            }
            .hFormContentPosition(.center)
            .hFormAttachToBottom {
                hSection {
                    VStack(spacing: 8) {
                        if let actionButton = buttons.actionButtonAttachedToBottom {
                            hButton.LargeButton(type: .primary) {
                                actionButton.buttonAction()
                            } content: {
                                hText(actionButton.buttonTitle ?? "")
                            }
                        }
                        if let dismissButton = buttons.dismissButton {
                            hButton.LargeButton(type: .ghost) {
                                dismissButton.buttonAction()
                            } content: {
                                hText(dismissButton.buttonTitle ?? L10n.openChat, style: .body)
                            }
                        }
                    }
                }
                .sectionContainerStyle(.transparent)
                .padding(.vertical, 16)
            }
        } else {
            content
        }
    }

    private var content: some View {
        VStack(spacing: 16) {
            switch icon {
            case .triangle:
                Image(uiImage: hCoreUIAssets.warningTriangleFilled.image)
                    .foregroundColor(hSignalColor.amberElement)
            case .circle:
                Image(uiImage: hCoreUIAssets.infoIconFilled.image)
                    .resizable()
                    .frame(width: 24, height: 24)
                    .foregroundColor(hSignalColor.blueElement)
            }
            VStack {
                if !withoutTitle {
                    hText(title ?? L10n.somethingWentWrong, style: .body)
                        .foregroundColor(hTextColor.primaryTranslucent)
                        .multilineTextAlignment(.center)
                }
                if let description {
                    hText(description, style: .body)
                        .multilineTextAlignment(.center)
                        .foregroundColor(hTextColor.secondaryTranslucent)
                }
            }
            if let actionButton = buttons.actionButton {
                hButton.MediumButton(type: .primary) {
                    actionButton.buttonAction()
                } content: {
                    hText(actionButton.buttonTitle ?? L10n.generalRetry, style: .body)
                }
                .fixedSize()
            }
        }
        .padding(.horizontal, 32)
        .padding(.bottom, extraBottomPadding ? 32 : 0)
    }
}

public enum ErrorIconType {
    case triangle
    case circle
}

public struct ErrorViewButtonConfig {
    fileprivate let actionButton: ErrorViewButton?
    fileprivate let actionButtonAttachedToBottom: ErrorViewButton?
    fileprivate let dismissButton: ErrorViewButton?

    public init(
        actionButton: ErrorViewButton? = nil,
        actionButtonAttachedToBottom: ErrorViewButton? = nil,
        dismissButton: ErrorViewButton? = nil
    ) {
        self.actionButton = actionButton
        self.actionButtonAttachedToBottom = actionButtonAttachedToBottom
        self.dismissButton = dismissButton
    }

    public struct ErrorViewButton {
        fileprivate let buttonTitle: String?
        fileprivate let buttonAction: () -> Void

        public init(buttonTitle: String? = nil, buttonAction: @escaping () -> Void) {
            self.buttonTitle = buttonTitle
            self.buttonAction = buttonAction
        }
    }
}

#Preview{
    GenericErrorView(
        icon: .circle,
        buttons:
            .init(
                actionButton:
                    .init(
                        buttonAction: {}),
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

private struct EnvironmenthWithoutTitle: EnvironmentKey {
    static let defaultValue: Bool = false
}

extension EnvironmentValues {
    public var hWithoutTitle: Bool {
        get { self[EnvironmenthWithoutTitle.self] }
        set { self[EnvironmenthWithoutTitle.self] = newValue }
    }
}

extension GenericErrorView {
    public var hWithoutTitle: some View {
        self.environment(\.hWithoutTitle, true)
    }
}

private struct EnvironmenthExtraBottomPadding: EnvironmentKey {
    static let defaultValue: Bool = false
}

extension EnvironmentValues {
    public var hExtraBottomPadding: Bool {
        get { self[EnvironmenthExtraBottomPadding.self] }
        set { self[EnvironmenthExtraBottomPadding.self] = newValue }
    }
}

extension GenericErrorView {
    public var hExtraBottomPadding: some View {
        self.environment(\.hExtraBottomPadding, true)
    }
}
