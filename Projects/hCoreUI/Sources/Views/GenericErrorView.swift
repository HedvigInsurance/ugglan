import SwiftUI
import hCore

public struct GenericErrorView: View {
    private let title: String?
    private let description: String?
    private let useForm: Bool
    private let buttons: ErrorViewButtonConfig
    private let attachContentToTheBottom: Bool

    @Environment(\.hExtraTopPadding) var extraTopPadding

    public init(
        title: String? = nil,
        description: String? = L10n.General.errorBody,
        useForm: Bool = true,
        buttons: ErrorViewButtonConfig,
        attachContentToTheBottom: Bool = false
    ) {
        self.title = title
        self.description = description
        self.useForm = useForm
        self.buttons = buttons
        self.attachContentToTheBottom = attachContentToTheBottom
    }

    public var body: some View {
        if useForm {
            hForm {
                if !attachContentToTheBottom {
                    content
                        .padding(.bottom, .padding32)
                        .padding(.top, extraTopPadding ? 32 : 0)
                }
            }
            .hFormContentPosition(.center)
            .hFormAttachToBottom {
                hSection {
                    VStack(spacing: 8) {
                        if attachContentToTheBottom {
                            content
                                .padding(.bottom, .padding40)
                                .padding(.top, extraTopPadding ? 32 : 0)
                        }
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
                                hText(dismissButton.buttonTitle ?? L10n.openChat, style: .body1)
                            }
                        }
                    }
                }
                .sectionContainerStyle(.transparent)
                .padding(.vertical, .padding16)
            }
        } else {
            content
        }
    }

    private var content: some View {
        StateView(
            type: .error,
            title: title ?? L10n.somethingWentWrong,
            bodyText: description,
            button: buttons.actionButton != nil
                ? .init(
                    buttonTitle: buttons.actionButton?.buttonTitle,
                    buttonAction: buttons.actionButton?.buttonAction ?? {}
                ) : nil
        )
    }
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

struct Error_Previews: PreviewProvider {
    static var previews: some View {
        GenericErrorView(
            buttons:
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

struct ErrorAttachToBottom_Previews: PreviewProvider {
    static var previews: some View {
        GenericErrorView(
            buttons:
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
                ),
            attachContentToTheBottom: true
        )
    }
}

private struct EnvironmenthExtraTopPadding: EnvironmentKey {
    static let defaultValue: Bool = false
}

extension EnvironmentValues {
    public var hExtraTopPadding: Bool {
        get { self[EnvironmenthExtraTopPadding.self] }
        set { self[EnvironmenthExtraTopPadding.self] = newValue }
    }
}

extension View {
    public var hExtraTopPadding: some View {
        self.environment(\.hExtraTopPadding, true)
    }
}
