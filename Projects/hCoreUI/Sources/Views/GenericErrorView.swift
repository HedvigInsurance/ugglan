import SwiftUI
import hCore

public struct GenericErrorView: View {
    private let title: String?
    private let description: String?
    private let useForm: Bool

    private let attachContentToTheBottom: Bool

    @Environment(\.hExtraTopPadding) var extraTopPadding
    @Environment(\.hErrorViewButtonConfig) var errorViewButtonConfig

    public init(
        title: String? = nil,
        description: String? = L10n.General.errorBody,
        useForm: Bool = true,
        attachContentToTheBottom: Bool = false
    ) {
        self.title = title
        self.description = description
        self.useForm = useForm
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
                        if let actionButton = errorViewButtonConfig?.actionButtonAttachedToBottom {
                            hButton.LargeButton(type: .primary) {
                                actionButton.buttonAction()
                            } content: {
                                hText(actionButton.buttonTitle ?? "")
                            }
                        }
                        if let dismissButton = errorViewButtonConfig?.dismissButton {
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
            ZStack(alignment: .bottom) {
                VStack {
                    Spacer()
                    content
                    Spacer()
                }
            }
        }
    }

    private var content: some View {
        StateView(
            type: .error,
            title: title ?? L10n.somethingWentWrong,
            bodyText: description,
            button: errorViewButtonConfig?.actionButton != nil
                ? .init(
                    buttonTitle: errorViewButtonConfig?.actionButton?.buttonTitle,
                    buttonAction: errorViewButtonConfig?.actionButton?.buttonAction ?? {}
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

private struct ErrorViewButtonConfigKey: EnvironmentKey {
    static let defaultValue: ErrorViewButtonConfig? = nil
}

extension EnvironmentValues {
    public var hErrorViewButtonConfig: ErrorViewButtonConfig? {
        get { self[ErrorViewButtonConfigKey.self] }
        set { self[ErrorViewButtonConfigKey.self] = newValue }
    }
}

extension View {
    public func hErrorViewButtonConfig(_ errorViewButtonConfigKey: ErrorViewButtonConfig?) -> some View {
        self.environment(\.hErrorViewButtonConfig, errorViewButtonConfigKey)
    }
}

struct Error_Previews: PreviewProvider {
    static var previews: some View {
        GenericErrorView()
            .hErrorViewButtonConfig(
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
            attachContentToTheBottom: true
        )
        .hErrorViewButtonConfig(
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
