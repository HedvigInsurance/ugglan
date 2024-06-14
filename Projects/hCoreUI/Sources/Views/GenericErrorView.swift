import SwiftUI
import hCore

public struct GenericErrorView: View {
    private let title: String?
    private let description: String?
    private let useForm: Bool
    private let icon: ErrorIconType
    private let buttons: ErrorViewButtonConfig
    private let attachContentToTheBottom: Bool
    @Environment(\.hWithoutTitle) var withoutTitle
    @Environment(\.hExtraBottomPadding) var extraBottomPadding
    @Environment(\.hExtraTopPadding) var extraTopPadding
    @Environment(\.hUseNewDesign) var hUseNewDesign

    public init(
        title: String? = nil,
        description: String? = L10n.General.errorBody,
        useForm: Bool = true,
        icon: ErrorIconType = .triangle,
        buttons: ErrorViewButtonConfig,
        attachContentToTheBottom: Bool = false
    ) {
        self.title = title
        self.description = description
        self.useForm = useForm
        self.icon = icon
        self.buttons = buttons
        self.attachContentToTheBottom = attachContentToTheBottom
    }

    public var body: some View {
        if useForm {
            hForm {
                if !attachContentToTheBottom {
                    content
                        .padding(.bottom, 32)
                        .padding(.top, extraTopPadding ? 32 : 0)
                }
            }
            .hFormContentPosition(.center)
            .hFormAttachToBottom {
                hSection {
                    VStack(spacing: 8) {
                        if attachContentToTheBottom {
                            content
                                .padding(.bottom, 40)
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
                .padding(.vertical, 16)
            }
        } else {
            content
        }
    }

    private var content: some View {
        let imageDimension: CGFloat = hUseNewDesign ? 40 : 24
        return VStack(spacing: 16) {
            switch icon {
            case .triangle:
                hCoreUIAssets.warningTriangleFilled.view
                    .resizable()
                    .frame(width: imageDimension, height: imageDimension)
                    .foregroundColor(hSignalColor.Amber.element)
            case .circle:
                hCoreUIAssets.infoFilled.view
                    .resizable()
                    .frame(width: imageDimension, height: imageDimension)
                    .foregroundColor(hSignalColor.Blue.element)
            }
            VStack {
                if !withoutTitle {
                    hText(title ?? L10n.somethingWentWrong, style: .body1)
                        .foregroundColor(hTextColor.Translucent.primary)
                        .multilineTextAlignment(.center)
                }
                if let description {
                    hText(description, style: .body1)
                        .padding(.horizontal, 32)
                        .multilineTextAlignment(.center)
                        .foregroundColor(hTextColor.Translucent.secondary)
                }
            }
            if let actionButton = buttons.actionButton {
                hButton.MediumButton(type: .primary) {
                    actionButton.buttonAction()
                } content: {
                    hText(actionButton.buttonTitle ?? L10n.generalRetry, style: .body1)
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
